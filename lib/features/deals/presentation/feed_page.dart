import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/glass_colors.dart';
import '../../../widgets/affiliate_disclaimer.dart';
import '../../../widgets/app_footer.dart';
import '../../newsletter/presentation/newsletter_signup_section.dart';
import '../../settings/presentation/shimmer_grid.dart';
import '../providers/filtered_deals_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/deals_provider.dart';
import '../providers/paged_deals_provider.dart';
import '../providers/search_history_provider.dart';
import 'brand_logos_section.dart';
import 'glass_sticky_header.dart';
import 'feed_states.dart';
import 'live_status_banner.dart';
import 'page_controls.dart';
import 'search_history_overlay.dart';
import 'top_deals_sliver.dart';
import 'recently_viewed_sliver.dart';
import 'deal_slivers.dart';

part 'feed_page.g.dart';

/// The search field's [TextEditingController]/[FocusNode] are shared between
/// the app-level top nav bar (adaptive_scaffold.dart, which owns the search
/// box on wide screens) and this page's own toolbar (which owns it on
/// mobile, where there is no top nav bar) — both need the *same* instances,
/// so they're held here as plain (app-lifetime) providers rather than local
/// State fields that only one widget could own.
final searchControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final searchFocusNodeProvider = Provider<FocusNode>((ref) {
  final node = FocusNode();
  ref.onDispose(node.dispose);
  return node;
});

class _SearchDebouncer {
  Timer? _timer;
  void run(VoidCallback action) {
    cancel();
    _timer = Timer(const Duration(milliseconds: 300), action);
  }

  void cancel() => _timer?.cancel();
  void dispose() => _timer?.cancel();
}

final _searchDebouncerProvider = Provider<_SearchDebouncer>((ref) {
  final debouncer = _SearchDebouncer();
  ref.onDispose(debouncer.dispose);
  return debouncer;
});

/// Debounced search-query update, shared by every widget that renders the
/// search field (see [searchControllerProvider] above).
void handleSearchChanged(WidgetRef ref, String value) {
  ref.read(_searchDebouncerProvider).run(() {
    ref.read(feedFiltersProvider.notifier).updateSearchQuery(value);
    if (value.trim().isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).add(value);
    }
  });
}

/// Cancels any pending debounced keystroke update — call before an
/// immediate, discrete search-query change (e.g. tapping a brand/category
/// link) so a stale in-flight keystroke update can't overwrite it a moment
/// later.
void cancelPendingSearchUpdate(WidgetRef ref) {
  ref.read(_searchDebouncerProvider).cancel();
}

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

/// Horizontal gutter for the hero surface: centers it at a 1200px max width
/// on wide screens (per the "Layout Structure" design directive) while
/// keeping a sensible fixed gutter on narrower ones.
double _heroHorizontalPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  const maxContentWidth = 1200;
  const minGutter = 16.0;
  return width > maxContentWidth + minGutter * 2
      ? (width - maxContentWidth) / 2
      : minGutter;
}

/// The large gradient-glass "hero" surface housing the deal feed.
final _heroDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      GlassColors.surface.withValues(alpha: 0.7),
      GlassColors.background.withValues(alpha: 0.55),
    ],
  ),
  borderRadius: BorderRadius.circular(28),
  border: Border.all(color: GlassColors.glowBorder),
  boxShadow: [
    BoxShadow(
      color: GlassColors.glowBorder.withValues(alpha: 0.2),
      blurRadius: 40,
      spreadRadius: -8,
    ),
  ],
);

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  // Shared with the app-level top nav bar (see searchControllerProvider doc)
  // — sourced once here, not created locally, and NOT disposed by this page
  // since Riverpod owns their lifetime.
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  final _isRefreshing = ValueNotifier<bool>(false);
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = ref.read(searchControllerProvider);
    _searchFocusNode = ref.read(searchFocusNodeProvider);
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _isRefreshing.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onBrandTap(String brandName) {
    cancelPendingSearchUpdate(ref);
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

  void _onFooterShopTap(String category) {
    cancelPendingSearchUpdate(ref);
    _searchController.clear();
    ref.read(feedFiltersProvider.notifier).updateCategory(category);
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

  /// True when no search/category/favorites filter is active — the default
  /// "browse everything" state, where the grid is paginated server-side
  /// ([pagedDealsProvider]). Any filter switches to client-side pagination
  /// over the full, already-fetched catalog (`filteredDealsPageProvider`),
  /// since category/favorites matching is client-only logic the API can't
  /// apply.
  bool _isPagedBrowseMode(FeedFilters filters) {
    return filters.searchQuery.isEmpty &&
        filters.category == 'All' &&
        !filters.showFavoritesOnly;
  }

  void _onPageChanged(WidgetRef ref, int page) {
    ref.read(feedPageIndexProvider.notifier).setPage(page);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildDealsGridSliver(WidgetRef ref, bool isPagedBrowseMode) {
    if (isPagedBrowseMode) {
      final pagedAsync = ref.watch(pagedDealsProvider);
      return DealsSliver(
        deals: pagedAsync.value?.items ?? const [],
        isLoading: pagedAsync.isLoading && !pagedAsync.hasValue,
        error: pagedAsync.hasError && !pagedAsync.hasValue
            ? pagedAsync.error
            : null,
        isEmpty:
            !pagedAsync.isLoading && (pagedAsync.value?.items.isEmpty ?? false),
        onFavoriteTap: (deal) =>
            ref.read(favoritesProvider.notifier).handleFavoriteTap(context, deal),
      );
    }

    final page = ref.watch(filteredDealsPageProvider);
    return DealsSliver(
      deals: page.items,
      isEmpty: page.items.isEmpty,
      onFavoriteTap: (deal) =>
          ref.read(favoritesProvider.notifier).handleFavoriteTap(context, deal),
    );
  }

  Widget _buildPageControlsSliver(WidgetRef ref, bool isPagedBrowseMode) {
    final totalPages = isPagedBrowseMode
        ? (ref.watch(pagedDealsProvider).value?.totalPages ?? 1)
        : ref.watch(filteredDealsPageProvider).totalPages;

    return SliverToBoxAdapter(
      child: PageControls(
        currentPage: ref.watch(feedPageIndexProvider),
        totalPages: totalPages,
        onPageChanged: (page) => _onPageChanged(ref, page),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing.value) return;

    _isRefreshing.value = true;
    ref.invalidate(pagedDealsProvider);
    await ref.read(dealFeedProvider.notifier).refresh();
    _isRefreshing.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(feedFiltersProvider);
    final displayDeals = ref.watch(
      filteredDealsProvider,
    ); // This is now optimized
    final dealFeedAsync = ref.watch(dealFeedProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final isPagedBrowseMode = _isPagedBrowseMode(filters);

    // The default browse view's main grid is server-paginated (see
    // pagedDealsProvider) precisely so it doesn't have to wait on
    // dealFeedProvider's full-catalog fetch — which, as the catalog grows,
    // can take far longer than a single page. Only fall back to gating on
    // the full fetch when a filter is active, since filtering genuinely
    // needs that full catalog (see _isPagedBrowseMode).
    final pagedAsync = ref.watch(pagedDealsProvider);
    final bool isInitialLoading;
    final bool hasLoadError;
    final Object? loadError;
    final bool feedIsEmpty;
    if (isPagedBrowseMode) {
      isInitialLoading = pagedAsync.isLoading && !pagedAsync.hasValue;
      hasLoadError = pagedAsync.hasError && !pagedAsync.hasValue;
      loadError = pagedAsync.error;
      feedIsEmpty = !isInitialLoading &&
          !hasLoadError &&
          (pagedAsync.value?.totalCount ?? 0) == 0;
    } else {
      isInitialLoading = dealFeedAsync.isLoading && !dealFeedAsync.hasValue;
      hasLoadError = dealFeedAsync.hasError && !dealFeedAsync.hasValue;
      loadError = dealFeedAsync.error;
      feedIsEmpty = !isInitialLoading &&
          !hasLoadError &&
          (dealFeedAsync.asData?.value ?? []).isEmpty;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      // The app-level top nav bar (adaptive_scaffold.dart) already covers
      // logo/tabs/categories/search/auth on wide screens, so the feed's own
      // header is only needed on narrow/mobile screens (no top nav bar
      // there). Refresh lives in the floating button below instead of a
      // toolbar row on either layout.
      appBar: isWide
          ? null
          : const GlassStickyHeader(),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: GlassColors.backgroundGradient),
        child: Column(
          children: [
            // ─── Main Content ────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: isInitialLoading
                        ? const ShimmerGrid(isGrid: true)
                        : hasLoadError
                        ? ErrorState(
                            message: 'ERROR: ${loadError.toString()}',
                            onRetry: () => _handleRefresh(),
                          ) // Removed redundant handleRefresh call
                        : feedIsEmpty
                        ? EmptyState(onRefresh: () => _handleRefresh())
                        : (filters.searchQuery.isNotEmpty ||
                                  filters.showFavoritesOnly) &&
                              displayDeals.isEmpty
                        ? SearchEmptyState(
                            query: filters.searchQuery,
                            onClear: () {
                              cancelPendingSearchUpdate(ref);
                              _searchController.clear();
                              ref.read(feedFiltersProvider.notifier).clear();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          )
                        : CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              // ---- Live status banner: a slim, centered
                              // glass pill floating directly on the page's
                              // background gradient — extra top inset here
                              // is the "breathing room" gap between the
                              // header/nav bar and the feed. ----
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  _heroHorizontalPadding(context),
                                  32,
                                  _heroHorizontalPadding(context),
                                  0,
                                ),
                                sliver: const SliverToBoxAdapter(
                                  child: Center(child: LiveStatusBanner()),
                                ),
                              ),

                              // ---- Recently Viewed: deliberately kept
                              // OUTSIDE the boxed hero surface below so it
                              // floats transparently on the page's own
                              // gradient rather than sitting in its own
                              // dark container — each card is still a
                              // GlassCard, same as the main grid. ----
                              if (filters.searchQuery.isEmpty &&
                                  !filters.showFavoritesOnly)
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _heroHorizontalPadding(
                                      context,
                                    ),
                                  ),
                                  sliver: const SliverMainAxisGroup(
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: SizedBox(height: 20),
                                      ),
                                      RecentlyViewedSliver(),
                                    ],
                                  ),
                                ),

                              // ---- Hero surface: a large, centered
                              // (max-width 1200) gradient-glass panel housing
                              // the core deal feed — Insane Deals and the
                              // main grid. ----
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  _heroHorizontalPadding(context),
                                  20,
                                  _heroHorizontalPadding(context),
                                  16,
                                ),
                                sliver: DecoratedSliver(
                                  decoration: _heroDecoration,
                                  sliver: SliverMainAxisGroup(
                                    slivers: [
                                      if (filters.searchQuery.isEmpty &&
                                          !filters.showFavoritesOnly)
                                        const TopDealsSliver(),
                                      SliverPadding(
                                        padding: const EdgeInsets.all(20),
                                        sliver: _buildDealsGridSliver(
                                          ref,
                                          isPagedBrowseMode,
                                        ),
                                      ),
                                      _buildPageControlsSliver(
                                        ref,
                                        isPagedBrowseMode,
                                      ),
                                      const SliverToBoxAdapter(
                                        child: AffiliateDisclaimer(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // ---- Featured brands + newsletter, then the
                              // app footer — always shown regardless of the
                              // active search/filter state, full-width
                              // outside the hero surface. ----
                              SliverToBoxAdapter(
                                child: BrandLogosSection(
                                  onBrandTap: _onBrandTap,
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: NewsletterSignupSection(),
                              ),
                              SliverToBoxAdapter(
                                child: AppFooter(onShopCategoryTap: _onFooterShopTap),
                              ),
                            ],
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
      ),
    );
  }
}

// ─── Shimmer skeleton loading ─────────────────────────────────────────────────

// ─── Empty / Error states ─────────────────────────────────────────────────────
