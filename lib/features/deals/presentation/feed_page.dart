import 'dart:async';
import 'dart:ui' as ui;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/deal_card.dart';
import '../domain/deal.dart';
import '../providers/deals_provider.dart';
import '../data/favorites_repository.dart';
import '../providers/recently_viewed_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/profile_page.dart' as profile_page;
import '../../alerts/presentation/price_alert_modal.dart';
import '../../../services/share_service.dart';
import '../../auth/presentation/login_page.dart';

import '../../../widgets/glass_dialog.dart';
import '../../legal/presentation/about_us_page.dart';
import '../../legal/presentation/privacy_policy_page.dart';
import '../../legal/presentation/terms_of_service_page.dart';

part 'feed_page.g.dart';

@immutable
class FeedFilters {
  const FeedFilters({
    this.searchQuery = '',
    this.sort = ProductSort.none,
    this.category = 'All',
    this.showFavoritesOnly = false,
  });

  final String searchQuery;
  final ProductSort sort;
  final String category;
  final bool showFavoritesOnly;

  FeedFilters copyWith({
    String? searchQuery,
    ProductSort? sort,
    String? category,
    bool? showFavoritesOnly,
  }) {
    return FeedFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      sort: sort ?? this.sort,
      category: category ?? this.category,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
    );
  }
}

enum ProductSort { none, priceAsc, priceDesc }

enum FeedView { grid, list }

// ─── Feed page ─────────────────────────────────────────────────────────────────

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';
  void update(String query) => state = query;
  void clear() => state = '';
}

@riverpod
class Region extends _$Region {
  @override
  String build() {
    // 1. Calculate the system default instantly so the app doesn't freeze
    final locale = ui.PlatformDispatcher.instance.locale;
    final country = locale.countryCode?.toUpperCase();
    final language = locale.languageCode.toLowerCase();

    String defaultRegion = 'se';
    if (country == 'NO' ||
        language == 'no' ||
        language == 'nb' ||
        language == 'nn') {
      defaultRegion = 'no';
    }

    // 2. Fire off a background task to check for a saved user preference
    _loadSavedRegion();

    // 3. Return the default immediately. If a saved preference is found,
    // it will smoothly update the state a millisecond later.
    return defaultRegion;
  }

  Future<void> _loadSavedRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRegion = prefs.getString('user_selected_region');
    if (savedRegion != null) {
      state =
          savedRegion; // Updates the UI automatically if a saved region exists
    }
  }

  Future<void> setRegion(String newRegion) async {
    // Save to device storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_selected_region', newRegion);

    // Instantly update the UI state
    state = newRegion;
  }
}

@riverpod
class FeedFiltersNotifier extends _$FeedFiltersNotifier {
  @override
  FeedFilters build() {
    //_loadInitialState(); // It's okay for this to be async here
    return const FeedFilters();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateSort(ProductSort sort) {
    state = state.copyWith(sort: sort);
  }

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void toggleFavoritesOnly() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }

  void clear() {
    state = state.copyWith(
      searchQuery: '',
      category: 'All',
      showFavoritesOnly: false,
    );
  }
}

@riverpod
class FeedViewMode extends _$FeedViewMode {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@Riverpod(keepAlive: true)
class FavoritesNotifier extends _$FavoritesNotifier {
  @override
  Future<Set<String>> build() async {
    final authState = ref.watch(authProvider);
    final user = authState.value;

    final repo = await ref.watch(favoritesRepositoryProvider.future);
    return repo.getFavorites(user);
  }

  /// Clears all favorites from storage and state.
  Future<void> clear() async {
    final user = ref.read(authProvider).value;
    final repo = await ref.read(favoritesRepositoryProvider.future);
    await repo.clearFavorites(user);
    state = const AsyncValue.data({});
  }

  Future<void> toggleFavorite(String productId) async {
    final user = ref.read(authProvider).value;

    // Optimistic update: update the UI immediately
    final previousState = state;
    if (previousState.hasValue) {
      final newFavs = Set<String>.from(previousState.value!);
      if (newFavs.contains(productId)) {
        newFavs.remove(productId);
      } else {
        newFavs.add(productId);
      }
      state = AsyncValue.data(newFavs);
    }

    try {
      final repo = await ref.read(favoritesRepositoryProvider.future);
      // The repository handles the actual data update.
      await repo.toggleFavorite(productId, user);
    } catch (e) {
      // If the update fails, revert to the previous state.
      state = previousState;
    }
  }
}

String _formatAmount(double price) {
  final rounded = price.round();
  final s = rounded.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

// HELPER FUNCTION FOR format all_no and all_se
String formatSourceName(String rawSource) {
  if (rawSource.toLowerCase().contains('all_no') ||
      rawSource.toLowerCase().contains('all no')) {
    return 'Norway Deals 🇳🇴';
  } else if (rawSource.toLowerCase().contains('all_se') ||
      rawSource.toLowerCase().contains('all se')) {
    return 'Sweden Deals 🇸🇪';
  }
  return rawSource; // Fallback
}

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final _searchController = TextEditingController();
  final _isRefreshing = ValueNotifier<bool>(false);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _isRefreshing.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing.value) return;
    _isRefreshing.value = true;
    try {
      await ref.read(dealFeedProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deals refreshed successfully!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh deals.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      _isRefreshing.value = false;
    }
  }

  void _handlePriceAlertTap(Deal deal) {
    // Check if user is logged in. Use authProvider here.
    final user = ref.read(authProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to set price alerts.'),
          action: SnackBarAction(
            label: 'SIGN IN',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ),
      );
    } else {
      showPriceAlertModal(
        context: context,
        ref: ref,
        productId: deal.id,
        title: deal.title,
        url: deal.url,
        currentPrice: deal.currentPrice,
        currency: deal.currency,
      );
    }
  }

  void _handleFavoriteTap(Deal deal) {
    final user = ref.read(authProvider).value;
    if (user != null && !user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email to manage favorites.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref.read(favoritesProvider.notifier).toggleFavorite(deal.id);
  }

  @override
  Widget build(BuildContext context) {
    final dealFeedAsync = ref.watch(dealFeedProvider);
    final deals = dealFeedAsync.asData?.value ?? [];
    final filters = ref.watch(feedFiltersProvider); // This is fine
    final favorites = ref.watch(favoritesProvider);

    final isGrid = ref.watch(feedViewModeProvider); // Corrected provider name
    final authState = ref.watch(authProvider); // Use the correct auth provider

    final region = ref.watch(regionProvider);

    // Dynamically build a list of categories (sources) based on available deals
    final categories = {'All'};
    for (final d in deals) {
      if (d.source.isNotEmpty) categories.add(d.source);
    }
    final categoryList = categories.toList()
      ..sort((a, b) => a == 'All' ? -1 : a.compareTo(b));

    final displayDeals = deals.where((d) {
      if (filters.showFavoritesOnly &&
          !(favorites.asData?.value.contains(d.id) ?? false)) {
        return false;
      }

      final q = filters.searchQuery.toLowerCase();
      final matchesSearch =
          d.title.toLowerCase().contains(q) ||
          d.source.toLowerCase().contains(q);
      final matchesCategory =
          filters.category == 'All' || d.source == filters.category;
      return matchesSearch && matchesCategory;
    }).toList();

    // Apply the active sorting method
    switch (filters.sort) {
      case ProductSort.priceAsc:
        displayDeals.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case ProductSort.priceDesc:
        displayDeals.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case ProductSort.none:
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('DealFinder'),
        actions: [
          // ─── 2. Your existing action icons ──────────────────────────────
          authState.when(
            data: (user) => IconButton(
              tooltip: user != null ? 'Profile' : 'Sign In',
              icon: Icon(
                user != null ? Icons.account_circle : Icons.person_outline,
              ),
              onPressed: () {
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const profile_page.ProfilePage(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox.shrink(),
            ),
            error: (e, s) => const Icon(Icons.error),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isRefreshing,
            builder: (context, isRefreshing, _) => IconButton(
              tooltip: 'Refresh',
              onPressed: isRefreshing ? null : () => _handleRefresh(),
              icon: isRefreshing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
          ),
          // ... Keep your favorite, grid, filter, and sort buttons exactly as they were!
          IconButton(
            tooltip: filters.showFavoritesOnly ? 'Show All' : 'Show Favorites',
            icon: Badge(
              isLabelVisible: favorites.asData?.value.isNotEmpty ?? false,
              child: Icon(
                filters.showFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
            ),
            color: filters.showFavoritesOnly ? const Color(0xFFFF4757) : null,
            onPressed: () =>
                ref.read(feedFiltersProvider.notifier).toggleFavoritesOnly(),
          ),
          IconButton(
            tooltip: isGrid ? 'List View' : 'Grid View',
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => ref.read(feedViewModeProvider.notifier).toggle(),
          ),
          PopupMenuButton<String>(
            icon: Text(
              region == 'no' ? '🇳🇴' : '🇸🇪',
              style: const TextStyle(fontSize: 20),
            ),
            tooltip: 'Select Region',
            onSelected: (value) {
              // Instantly swap the database region
              ref
                  .read(regionProvider.notifier)
                  .setRegion(value); // This is now async
              // Refresh the feed to pull the new country's deals
              ref.read(dealFeedProvider.notifier).refresh();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'se', child: Text('🇸🇪 Sweden')),
              PopupMenuItem(value: 'no', child: Text('🇳🇴 Norway')),
            ],
          ),
          PopupMenuButton<String>(
            icon: Badge(
              isLabelVisible: filters.category != 'All',
              backgroundColor: const Color(0xFF00B4FF),
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter by Category',
            initialValue: filters.category,
            onSelected: (value) =>
                ref.read(feedFiltersProvider.notifier).updateCategory(value),
            itemBuilder: (context) => [
              for (final cat in categoryList)
                PopupMenuItem(value: cat, child: Text(formatSourceName(cat))),
            ],
          ),
          PopupMenuButton<ProductSort>(
            icon: Badge(
              isLabelVisible: filters.sort != ProductSort.none,
              backgroundColor: const Color(0xFF00B4FF),
              child: const Icon(Icons.sort),
            ),
            tooltip: 'Sort products',
            initialValue: filters.sort,
            onSelected: (value) =>
                ref.read(feedFiltersProvider.notifier).updateSort(value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ProductSort.none,
                child: Text('Default Sorting'),
              ),
              PopupMenuItem(
                value: ProductSort.priceAsc,
                child: Text('Price: Low to High'),
              ),
              PopupMenuItem(
                value: ProductSort.priceDesc,
                child: Text('Price: High to Low'),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // --- Gradient container ---
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00B4FF),
                  Color(0xFF0047FF),
                ], // Electric blue gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B4FF).withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Real Deals. No Noise.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tracking ${deals.length}+ price drops across top Nordic retailers today.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // ─── Search Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search products or brands...',
              leading: const Icon(Icons.search, color: Color(0xFF5A5A78)),
              trailing: [
                if (filters.searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF5A5A78)),
                    onPressed: () {
                      _debounce?.cancel();
                      _searchController.clear();
                      ref
                          .read(feedFiltersProvider.notifier)
                          .updateSearchQuery('');
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
              ],
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(const Color(0xFF1A1B2A)),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  ref
                      .read(feedFiltersProvider.notifier)
                      .updateSearchQuery(value);
                });
              },
            ),
          ),
          // ─── Main Content ────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: dealFeedAsync.isLoading && !dealFeedAsync.hasValue
                  ? _ShimmerGrid(isGrid: isGrid)
                  : dealFeedAsync.hasError
                  ? _ErrorState(
                      message: 'ERROR: ${dealFeedAsync.error.toString()}',
                      onRetry: () => _handleRefresh(),
                    )
                  : deals.isEmpty
                  ? _EmptyState(onRefresh: () => _handleRefresh())
                  : displayDeals.isEmpty
                  ? _SearchEmptyState(
                      query: filters.searchQuery,
                      onClear: () {
                        _debounce?.cancel();
                        _searchController.clear();
                        ref.read(feedFiltersProvider.notifier).clear();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: CustomScrollView(
                        key: ValueKey(isGrid),
                        slivers: [
                          if (filters.searchQuery.isEmpty &&
                              !filters.showFavoritesOnly)
                            const _TopDealsSliver(),
                          if (filters.searchQuery.isEmpty &&
                              !filters.showFavoritesOnly)
                            const _RecentlyViewedSliver(),
                          SliverPadding(
                            padding: EdgeInsets.all(isGrid ? 20 : 14),
                            sliver: isGrid
                                ? SliverGrid.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          // Responsive cross-axis count
                                          crossAxisCount:
                                              (MediaQuery.of(
                                                        context,
                                                      ).size.width /
                                                      200)
                                                  .floor()
                                                  .clamp(1, 4),
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          // Increased height to accommodate action buttons
                                          mainAxisExtent: 130,
                                        ),
                                    itemCount: displayDeals.length,
                                    itemBuilder: (context, index) {
                                      final deal = displayDeals[index];
                                      return DealCard(
                                        deal: deal,
                                        displayPrice: deal.currentPrice,
                                        onTap: () {
                                          ref
                                              .read(
                                                recentlyViewedProvider.notifier,
                                              )
                                              .addDeal(deal.id);
                                          launchUrl(
                                            Uri.parse(deal.url),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        currency: deal.currency,
                                        onShare: () => ShareService.shareDeal(
                                          title: deal.title,
                                          url: deal.url,
                                        ),
                                        trailingActions: [
                                          IconButton(
                                            icon: Icon(
                                              (favorites.asData?.value.contains(
                                                        deal.id,
                                                      ) ??
                                                      false)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color:
                                                  (favorites.asData?.value
                                                          .contains(deal.id) ??
                                                      false)
                                                  ? const Color(0xFFFF4757)
                                                  : const Color(0xFF5A5A78),
                                            ),
                                            onPressed: () =>
                                                _handleFavoriteTap(deal),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : SliverList.separated(
                                    itemCount: displayDeals.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final deal = displayDeals[index];
                                      return DealCard(
                                        deal: deal,
                                        displayPrice: deal.currentPrice,
                                        onTap: () {
                                          ref
                                              .read(
                                                recentlyViewedProvider.notifier,
                                              )
                                              .addDeal(deal.id);
                                          launchUrl(
                                            Uri.parse(deal.url),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        currency: deal.currency,
                                        onShare: () => ShareService.shareDeal(
                                          title: deal.title,
                                          url: deal.url,
                                        ),
                                        trailingActions: [
                                          IconButton(
                                            icon: Icon(
                                              (favorites.asData?.value.contains(
                                                        deal.id,
                                                      ) ??
                                                      false)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color:
                                                  (favorites.asData?.value
                                                          .contains(deal.id) ??
                                                      false)
                                                  ? const Color(0xFFFF4757)
                                                  : const Color(0xFF5A5A78),
                                            ),
                                            onPressed: () =>
                                                _handleFavoriteTap(deal),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),

                          // ---- AFFILIATE DISCLAIMER ----
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                'PrisPuls is reader-supported. When you buy through links on our site, we may earn an affiliate commission.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF5A5A78),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recently Viewed section ────────────────────────────────────────────────

class _RecentlyViewedSliver extends ConsumerWidget {
  const _RecentlyViewedSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentIds = ref.watch(recentlyViewedProvider);
    final dealFeedAsync = ref.watch(dealFeedProvider);

    if (recentIds.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return dealFeedAsync.when(
      loading: () => const _TopDealsShimmer(), // Reuse the same shimmer
      error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (allDeals) {
        if (allDeals.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        // Create a map for quick lookups
        final dealMap = {for (var deal in allDeals) deal.id: deal};

        // Filter and order deals based on recentIds
        final recentDeals = recentIds
            .map((id) => dealMap[id])
            .where((deal) => deal != null)
            .cast<Deal>()
            .toList();

        if (recentDeals.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return _RecentlyViewedSliverContent(recentDeals: recentDeals);
      },
    );
  }
}

class _RecentlyViewedSliverContent extends ConsumerWidget {
  const _RecentlyViewedSliverContent({required this.recentDeals});
  final List<Deal> recentDeals;

  Future<void> _clearRecents(BuildContext context, WidgetRef ref) async {
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: const Text('Clear History'),
      content: const Text(
        'Are you sure you want to clear your recently viewed items?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF4757)),
          child: const Text('Clear'),
        ),
      ],
    );

    if (confirm == true) {
      ref.read(recentlyViewedProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF8A8AA0),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Recently Viewed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _clearRecents(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8A8AA0),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 192,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentDeals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _TopDealCard(deal: recentDeals[i]),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFF252638)),
        ],
      ),
    );
  }
}

// ─── Top deals section ────────────────────────────────────────────────────────

class _TopDealsSliver extends ConsumerWidget {
  const _TopDealsSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topDealsAsync = ref.watch(topDealsProvider);

    return topDealsAsync.when(
      loading: () => const _TopDealsShimmer(),
      error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (topDeals) {
        if (topDeals.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return _TopDealsSliverContent(topDeals: topDeals);
      },
    );
  }
}

class _TopDealsSliverContent extends StatelessWidget {
  const _TopDealsSliverContent({required this.topDeals});
  final List<Deal> topDeals;

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get screen constraints for responsiveness.
    return LayoutBuilder(
      builder: (context, constraints) {
        // --- Responsive Grid Calculation ---
        const double cardWidth = 148;
        const double cardHeight = 192;
        const double horizontalPadding = 16.0;
        const double spacing = 10.0;

        // Calculate how many columns can fit.
        final crossAxisCount =
            (constraints.maxWidth - horizontalPadding * 2 + spacing) ~/
            (cardWidth + spacing);

        // Determine how many rows are needed.
        final rowCount = (topDeals.length / crossAxisCount).ceil();

        // Calculate the total height required for the grid.
        final totalHeight =
            rowCount * cardHeight + (rowCount - 1) * spacing + 48;

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopDealsHeader(),
              SizedBox(
                height: totalHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 10,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: cardWidth / cardHeight,
                  ),
                  itemCount: topDeals.length,
                  itemBuilder: (context, index) {
                    return _TopDealCard(deal: topDeals[index]);
                  },
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFF252638)),
            ],
          ),
        );
      },
    );
  }
}

class _TopDealsHeader extends StatelessWidget {
  const _TopDealsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFFF6B35),
            size: 18,
          ),
          const SizedBox(width: 6),
          const Text(
            'Insane Deals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 230, 118, 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '≥ 25% off',
              style: TextStyle(
                color: Color(0xFF00E676),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopDealCard extends StatelessWidget {
  const _TopDealCard({required this.deal});
  final Deal deal;

  @override
  Widget build(BuildContext context) {
    final pct = deal.discountPercent?.round() ?? 0;

    return GestureDetector(
      onTap: () async {
        // Consider adding this to recently viewed
        final uri = Uri.tryParse(deal.url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 148,
        height: 192,
        decoration: BoxDecoration(
          color: const Color(0xFF12131A),
          border: Border.all(color: const Color(0xFF252638)),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + discount badge ──────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: deal.imageUrl != null && deal.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: deal.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, err) => const ColoredBox(
                            color: Color(0xFF060919),
                            child: Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Color(0xFF3A3A58),
                                size: 28,
                              ),
                            ),
                          ),
                        )
                      : const ColoredBox(
                          color: Color(0xFF060919),
                          child: Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xFF3A3A58),
                              size: 28,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-$pct%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ── Details ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_formatAmount(deal.currentPrice)} ${deal.currency}',
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (deal.originalPrice != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        '${_formatAmount(deal.originalPrice!)} ${deal.currency}',
                        style: const TextStyle(
                          color: Color(0xFF5A5A78),
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Color(0xFF5A5A78),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopDealsShimmer extends StatelessWidget {
  const _TopDealsShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.25, end: 0.6),
        duration: const Duration(milliseconds: 1100),
        builder: (context, opacity, _) {
          final shimmerColor = const Color(
            0xFF272839,
          ).withAlpha((opacity * 255).round());
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Container(
                  height: 20,
                  width: 120,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              SizedBox(
                height: 192,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, _) =>
                      _TopDealSkeletonCard(shimmerColor: shimmerColor),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFF252638)),
            ],
          );
        },
      ),
    );
  }
}

class _TopDealSkeletonCard extends StatelessWidget {
  const _TopDealSkeletonCard({required this.shimmerColor});
  final Color shimmerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        border: Border.all(color: const Color(0xFF252638)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 100, width: double.infinity, color: shimmerColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 11,
                    width: 120,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 11,
                    width: 80,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 13,
                    width: 70,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 10,
                    width: 70,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer skeleton loading ─────────────────────────────────────────────────

class _ShimmerGrid extends StatefulWidget {
  const _ShimmerGrid({required this.isGrid});
  final bool isGrid;

  @override
  State<_ShimmerGrid> createState() => _ShimmerGridState();
}

class _ShimmerGridState extends State<_ShimmerGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
    lowerBound: 0.25,
    upperBound: 0.6,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: CustomScrollView(
        key: ValueKey(widget.isGrid), // Use the boolean directly as the key
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(widget.isGrid ? 20 : 14),
            sliver: widget.isGrid
                ? SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 130,
                        ),
                    itemCount: 6,
                    itemBuilder: (_, __) => AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) =>
                          _SkeletonCard(opacity: _controller.value),
                    ),
                  )
                : SliverList.separated(
                    itemCount: 5,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, __) => AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) =>
                          _SkeletonCard(opacity: _controller.value),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final shimmer = const Color(0xFF272839).withAlpha((opacity * 255).round());

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF252638)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 130,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 110, color: shimmer),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 13,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 13,
                        width: 140,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 16,
                        width: 90,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty / Error states ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  'No deals found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Check back later or tap refresh.'),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh now'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.query, required this.onClear});
  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_off_outlined,
                      size: 64,
                      color: Color(0xFF5A5A78),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      query.isNotEmpty
                          ? 'No results for "$query"'
                          : 'No deals match your filters',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try checking for typos or removing some filters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8A8AA0)),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear filters'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4757).withAlpha(30),
                        foregroundColor: const Color(0xFFFF4757),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
