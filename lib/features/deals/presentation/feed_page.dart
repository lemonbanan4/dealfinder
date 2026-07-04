import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/affiliate_disclaimer.dart';
import '../../../widgets/app_footer.dart';
import '../../newsletter/presentation/newsletter_signup_section.dart';
import '../../settings/presentation/shimmer_grid.dart';
import '../providers/filtered_deals_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/deals_provider.dart';
import '../providers/search_history_provider.dart';
import 'brand_logos_section.dart';
import 'feed_app_bar.dart';
import 'feed_header.dart';
import 'feed_states.dart';
import 'search_history_overlay.dart';
import 'top_deals_sliver.dart';
import 'recently_viewed_sliver.dart';
import 'deal_slivers.dart';

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

enum ProductSort { none, priceAsc, priceDesc, discountDesc }

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
    final country = locale.countryCode?.toUpperCase() ?? '';
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

final categoriesProvider = Provider<List<String>>((ref) {
  final dealFeedAsync = ref.watch(dealFeedProvider);
  final categories = <String>{'All'};
  for (final d in dealFeedAsync.asData?.value ?? []) {
    if (d.source.isNotEmpty) categories.add(d.source);
  }
  final categoryList = categories.toList()
    ..sort((a, b) => a == 'All' ? -1 : a.compareTo(b));
  return categoryList;
});

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final _searchController = TextEditingController();
  final _isRefreshing = ValueNotifier<bool>(false);
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    _isRefreshing.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onBrandTap(String brandName) {
    _debounce?.cancel();
    _searchController.text = brandName;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: brandName.length),
    );
    ref.read(feedFiltersProvider.notifier).updateSearchQuery(brandName);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  void _onSearchFocusChange() {
    setState(() {}); // Rebuild to show/hide history overlay
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing.value) return;

    _isRefreshing.value = true;
    await ref.read(dealFeedProvider.notifier).refresh();
    _isRefreshing.value = false;
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(feedFiltersProvider.notifier).updateSearchQuery(value);
      // Only add to history if the query is not empty
      if (value.trim().isNotEmpty) {
        ref.read(searchHistoryProvider.notifier).add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(feedFiltersProvider);
    final displayDeals = ref.watch(
      filteredDealsProvider,
    ); // This is now optimized
    final isGrid = ref.watch(feedViewModeProvider);
    final dealFeedAsync = ref.watch(dealFeedProvider);

    return Scaffold(
      appBar: FeedAppBar(
        isRefreshing: _isRefreshing,
        onRefresh: _handleRefresh,
      ),
      body: Column(
        children: [
          FeedHeader(
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            onSearchChanged: _onSearchChanged,
          ),
          // ─── Main Content ────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: dealFeedAsync.isLoading && !dealFeedAsync.hasValue
                      ? ShimmerGrid(isGrid: isGrid)
                      : dealFeedAsync.hasError && !dealFeedAsync.hasValue
                      ? ErrorState(
                          message: 'ERROR: ${dealFeedAsync.error.toString()}',
                          onRetry: () => _handleRefresh(),
                        ) // Removed redundant handleRefresh call
                      : (dealFeedAsync.asData?.value ?? []).isEmpty
                      ? EmptyState(onRefresh: () => _handleRefresh())
                      : (filters.searchQuery.isNotEmpty ||
                                filters.showFavoritesOnly) &&
                            displayDeals.isEmpty
                      ? SearchEmptyState(
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
                            controller: _scrollController,
                            slivers: [
                              if (filters.searchQuery.isEmpty &&
                                  !filters.showFavoritesOnly)
                                const TopDealsSliver(),
                              if (filters.searchQuery.isEmpty &&
                                  !filters.showFavoritesOnly)
                                const RecentlyViewedSliver(),
                              SliverPadding(
                                padding: EdgeInsets.all(isGrid ? 20 : 14),
                                sliver: DealsSliver(
                                  deals: displayDeals,
                                  view: isGrid ? FeedView.grid : FeedView.list,
                                  onFavoriteTap: (deal) => ref
                                      .read(favoritesProvider.notifier)
                                      .handleFavoriteTap(context, deal),
                                ),
                              ),

                              // ---- AFFILIATE DISCLAIMER ----
                              const SliverToBoxAdapter(
                                child: AffiliateDisclaimer(),
                              ),

                              // ---- Featured brands + newsletter, then the
                              // app footer — always shown regardless of the
                              // active search/filter state. ----
                              SliverToBoxAdapter(
                                child: BrandLogosSection(
                                  onBrandTap: _onBrandTap,
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: NewsletterSignupSection(),
                              ),
                              const SliverToBoxAdapter(child: AppFooter()),
                            ],
                          ),
                        ),
                ),
                // --- Search History Overlay ---
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child:
                      (_searchFocusNode.hasFocus &&
                          _searchController.text.isEmpty)
                      ? SearchHistoryOverlay(
                          onTap: (query) {
                            // Add to the top of the history list
                            ref.read(searchHistoryProvider.notifier).add(query);

                            // Set the text and perform the search
                            _searchController.text = query;
                            _searchController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: query.length),
                                );
                            ref
                                .read(feedFiltersProvider.notifier)
                                .updateSearchQuery(query);
                            _searchFocusNode.unfocus();
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer skeleton loading ─────────────────────────────────────────────────

// ─── Empty / Error states ─────────────────────────────────────────────────────
