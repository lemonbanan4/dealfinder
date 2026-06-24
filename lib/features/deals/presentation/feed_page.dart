import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/deal_card.dart';
import '../../../widgets/app_logo.dart';
import '../domain/deal.dart';
import '../providers/deals_provider.dart';
import '../../auth/presentation/auth_page.dart';
import '../../auth/presentation/profile_page.dart';
import '../../alerts/presentation/create_alert_sheet.dart';
import '../../../services/share_service.dart';

// ─── Feed page ─────────────────────────────────────────────────────────────────

// A simple provider to hold our current search query
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  () => SearchQueryNotifier(),
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
  void clear() => state = '';
}

enum ProductSort { none, priceAsc, priceDesc }

final productSortProvider = NotifierProvider<ProductSortNotifier, ProductSort>(
  () => ProductSortNotifier(),
);

class ProductSortNotifier extends Notifier<ProductSort> {
  static const _key = 'product_sort_pref';

  @override
  ProductSort build() {
    _loadPref();
    return ProductSort.none;
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key);
    if (index != null && index >= 0 && index < ProductSort.values.length) {
      state = ProductSort.values[index];
    }
  }

  Future<void> updateSort(ProductSort sort) async {
    state = sort;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, sort.index);
  }
}

final productCategoryProvider =
    NotifierProvider<ProductCategoryNotifier, String>(
      () => ProductCategoryNotifier(),
    );

class ProductCategoryNotifier extends Notifier<String> {
  static const _key = 'product_category_pref';

  @override
  String build() {
    _loadPref();
    return 'All';
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final category = prefs.getString(_key);
    if (category != null && category.isNotEmpty) {
      state = category;
    }
  }

  Future<void> updateCategory(String category) async {
    state = category;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, category);
  }
}

final showFavoritesOnlyProvider =
    NotifierProvider<ShowFavoritesOnlyNotifier, bool>(
      () => ShowFavoritesOnlyNotifier(),
    );

class ShowFavoritesOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void reset() => state = false;
}

final feedViewModeProvider = NotifierProvider<FeedViewModeNotifier, bool>(
  () => FeedViewModeNotifier(),
);

class FeedViewModeNotifier extends Notifier<bool> {
  static const _key = 'feed_view_mode_pref';

  @override
  bool build() {
    _loadPref();
    return false;
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final isGrid = prefs.getBool(_key);
    if (isGrid != null) state = isGrid;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  () => FavoritesNotifier(),
);

class FavoritesNotifier extends Notifier<Set<String>> {
  static const _key = 'favorite_products_pref';

  @override
  Set<String> build() {
    _loadPref();
    return {};
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_key);
    if (favs != null) state = favs.toSet();

    // Sync from Firestore if authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data.containsKey('favorites')) {
            final firestoreFavs = List<String>.from(data['favorites']);
            state = firestoreFavs.toSet();
            await prefs.setStringList(_key, firestoreFavs);
          }
        }
      } catch (e) {
        debugPrint('Failed to load favorites from Firestore: $e');
      }
    }
  }

  Future<void> toggleFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      throw Exception('Email not verified');
    }

    final newFavs = Set<String>.from(state);
    if (newFavs.contains(productId)) {
      newFavs.remove(productId);
    } else {
      newFavs.add(productId);
    }
    state = newFavs;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newFavs.toList());

    // Sync to Firestore if the user is authenticated
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'favorites': newFavs.toList(),
      }, SetOptions(merge: true));
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

  @override
  Widget build(BuildContext context) {
    final dealFeedAsync = ref.watch(dealFeedProvider);
    final deals = dealFeedAsync.value ?? [];
    final searchQuery = ref.watch(searchQueryProvider);
    final sortOption = ref.watch(productSortProvider);
    final selectedCategory = ref.watch(productCategoryProvider);
    final favorites = ref.watch(favoritesProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final isGrid = ref.watch(feedViewModeProvider);
    final authState = ref.watch(authStateProvider);

    // Dynamically build a list of categories (sources) based on available deals
    final categories = {'All'};
    for (final d in deals) {
      if (d.source.isNotEmpty) categories.add(d.source);
    }
    final categoryList = categories.toList()
      ..sort((a, b) => a == 'All' ? -1 : a.compareTo(b));

    final displayDeals = deals.where((d) {
      if (showFavoritesOnly && !favorites.contains(d.id)) return false;

      final q = searchQuery.toLowerCase();
      final matchesSearch =
          d.title.toLowerCase().contains(q) ||
          d.source.toLowerCase().contains(q);
      final matchesCategory =
          selectedCategory == 'All' || d.source == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Apply the active sorting method
    switch (sortOption) {
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
        title: const AppLogo(),
        actions: [
          IconButton(
            tooltip: authState.value != null ? 'Profile' : 'Sign In',
            icon: Icon(
              authState.value != null
                  ? Icons.account_circle
                  : Icons.person_outline,
            ),
            onPressed: () {
              if (authState.value != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              }
            },
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
          IconButton(
            tooltip: showFavoritesOnly ? 'Show All' : 'Show Favorites',
            icon: Icon(
              showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
            ),
            color: showFavoritesOnly ? const Color(0xFFFF4757) : null,
            onPressed: () =>
                ref.read(showFavoritesOnlyProvider.notifier).toggle(),
          ),
          IconButton(
            tooltip: isGrid ? 'List View' : 'Grid View',
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => ref.read(feedViewModeProvider.notifier).toggle(),
          ),
          PopupMenuButton<String>(
            icon: Badge(
              isLabelVisible: selectedCategory != 'All',
              backgroundColor: const Color(0xFF00B4FF),
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter by Category',
            initialValue: selectedCategory,
            onSelected: (value) => ref
                .read(productCategoryProvider.notifier)
                .updateCategory(value),
            itemBuilder: (context) => [
              for (final cat in categoryList)
                PopupMenuItem(value: cat, child: Text(cat)),
            ],
          ),
          PopupMenuButton<ProductSort>(
            icon: Badge(
              isLabelVisible: sortOption != ProductSort.none,
              backgroundColor: const Color(0xFF00B4FF),
              child: const Icon(Icons.sort),
            ),
            tooltip: 'Sort products',
            initialValue: sortOption,
            onSelected: (value) =>
                ref.read(productSortProvider.notifier).updateSort(value),
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
          // ─── Search Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search products or brands...',
              leading: const Icon(Icons.search, color: Color(0xFF5A5A78)),
              trailing: [
                if (searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF5A5A78)),
                    onPressed: () {
                      _debounce?.cancel();
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).clear();
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
                  ref.read(searchQueryProvider.notifier).updateQuery(value);
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
                      query: searchQuery,
                      onClear: () {
                        _debounce?.cancel();
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).clear();
                        ref
                            .read(productCategoryProvider.notifier)
                            .updateCategory('All');
                        ref.read(showFavoritesOnlyProvider.notifier).reset();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: CustomScrollView(
                        key: ValueKey(isGrid),
                        slivers: [
                          if (searchQuery.isEmpty && !showFavoritesOnly)
                            const _TopDealsSliver(),
                          SliverPadding(
                            padding: EdgeInsets.all(isGrid ? 20 : 14),
                            sliver: isGrid
                                ? SliverGrid.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          mainAxisExtent: 130,
                                        ),
                                    itemCount: displayDeals.length,
                                    itemBuilder: (context, index) {
                                      final deal = displayDeals[index];
                                      return DealCard(
                                        deal: deal,
                                        displayPrice: deal.currentPrice,
                                        currency: deal.currency,
                                        onShare: () => ShareService.shareDeal(
                                          title: deal.title,
                                          url: deal.url,
                                        ),
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
                                        currency: deal.currency,
                                        onShare: () => ShareService.shareDeal(
                                          title: deal.title,
                                          url: deal.url,
                                        ),
                                      );
                                    },
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

// ─── Top deals section ────────────────────────────────────────────────────────

class _TopDealsSliver extends ConsumerWidget {
  const _TopDealsSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topDeals = ref.watch(topDealsProvider).value ?? [];
    if (topDeals.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 230, 118, 0.15),
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
          ),
          SizedBox(
            height: 192,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: topDeals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _TopDealCard(deal: topDeals[i]),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFF252638)),
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
        final uri = Uri.tryParse(deal.url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
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

// ─── Shimmer skeleton loading ─────────────────────────────────────────────────

class _ShimmerGrid extends StatefulWidget {
  const _ShimmerGrid({required this.isGrid});
  final bool isGrid;

  @override
  State<_ShimmerGrid> createState() => _ShimmerGridState();
}

class _ShimmerGridState extends State<_ShimmerGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.25,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final isEntering = child.key == ValueKey(widget.isGrid);
          final offsetDir = widget.isGrid ? 1.0 : -1.0;
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: Offset(isEntering ? offsetDir : -offsetDir, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
        child: CustomScrollView(
          key: ValueKey(widget.isGrid),
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
                      itemBuilder: (_, _) =>
                          _SkeletonCard(opacity: _opacity.value),
                    )
                  : SliverList.separated(
                      itemCount: 5,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, _) =>
                          _SkeletonCard(opacity: _opacity.value),
                    ),
            ),
          ],
        ),
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
