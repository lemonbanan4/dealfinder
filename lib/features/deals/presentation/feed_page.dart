import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/glass_colors.dart';
import '../../../widgets/affiliate_disclaimer.dart';
import '../../../widgets/app_footer.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/glass_container.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/providers/auth_provider.dart';
import '../../newsletter/presentation/newsletter_signup_section.dart';
// Deferred: Settings (+ its Account/Preferences/Data & Privacy/Danger Zone
// subtree, cloud_functions, and the legal pages it links to) is a full-page
// navigation behind an icon tap, not part of the initial feed render — no
// reason to ship its code in the critical-path bundle everyone downloads
// before first paint. See https://flutter.dev/to/deferred-loading.
import '../../settings/presentation/settings_page.dart'
    deferred as settings_lib;
import '../../settings/presentation/shimmer_grid.dart';
import '../domain/deal.dart';
import '../providers/filtered_deals_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/deals_provider.dart';
import '../providers/paged_deals_provider.dart';
import '../providers/search_history_provider.dart';
import 'brand_logos_section.dart';
import 'glass_categories_menu.dart';
import 'glass_search_field.dart';
import 'glass_sticky_header.dart';
import 'feed_states.dart';
import 'live_status_banner.dart';
import 'page_controls.dart';
import 'search_history_overlay.dart';
import 'sort_dropdown.dart';
import 'top_deals_sliver.dart';
import 'trending_drops_sliver.dart';
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

enum ProductSort { none, priceAsc, priceDesc, newest }

// ─── Feed page ─────────────────────────────────────────────────────────────────

@riverpod
class Region extends _$Region {
  static const _prefsKey = 'user_selected_region';

  @override
  String build() {
    // 1. Calculate a locale-based guess instantly so first paint doesn't
    // wait on anything async. This is a weak signal (an English-language
    // browser physically in Norway would guess 'se'), so it's only ever
    // the fallback below, not the last word.
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

    // 2. Resolve the real region in the background: an explicit past choice
    // (Settings' region switch) always wins; otherwise upgrade the locale
    // guess with an IP-based geolocation lookup, which is far more reliable
    // than browser language.
    _resolveRegion();

    // 3. Return the locale guess immediately. Step 2 will smoothly update
    // the state a moment later if it finds something better.
    return defaultRegion;
  }

  Future<void> _resolveRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRegion = prefs.getString(_prefsKey);
    if (savedRegion != null) {
      state = savedRegion;
      return;
    }

    final geoRegion = await _fetchGeoRegion();
    if (geoRegion != null) {
      state = geoRegion;
    }
  }

  /// Best-effort IP geolocation via the backend's `/api/geo-region` — never
  /// throws; a slow/failed lookup just means the locale-based guess from
  /// [build] stands.
  Future<String?> _fetchGeoRegion() async {
    try {
      final response = await apiGet(
        '/api/geo-region',
        timeout: const Duration(seconds: 4),
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['region'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> setRegion(String newRegion) async {
    // Save to device storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, newRegion);

    // Instantly update the UI state
    state = newRegion;
  }
}

@riverpod
class FeedFiltersNotifier extends _$FeedFiltersNotifier {
  @override
  FeedFilters build() {
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

class _ScrollDownIntent extends Intent {
  const _ScrollDownIntent();
}

class _ScrollUpIntent extends Intent {
  const _ScrollUpIntent();
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

  /// Arrow-key page scroll. `Scrollable` already supports this out of the
  /// box, but only while it has keyboard focus — the instant a user clicks
  /// any card/button on the page (the common case, since the grid is wall-
  /// to-wall interactive cards), focus moves there and arrow keys stop
  /// reaching the scroll view. This app-wide [Shortcuts]/[Actions] pair
  /// (wrapping the whole page — see `build()`) catches ArrowUp/ArrowDown
  /// regardless of which descendant currently holds focus, as long as that
  /// descendant doesn't already handle the key itself (a text field with
  /// real cursor-movement semantics still wins, as it should).
  void _scrollByArrowKey(double delta) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = (_scrollController.offset + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
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
        onFavoriteTap: (deal) => ref
            .read(favoritesProvider.notifier)
            .handleFavoriteTap(context, deal),
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
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final isPagedBrowseMode = _isPagedBrowseMode(filters);

    // The default browse view's main grid is server-paginated (see
    // pagedDealsProvider) precisely so it doesn't have to wait on — or
    // even trigger — dealFeedProvider's full-catalog fetch, which as the
    // catalog grows can be a 20MB+ response. Only watch filteredDeals/
    // dealFeedProvider (which watching alone forces a fetch, regardless of
    // whether the result below ends up used) when a filter is genuinely
    // active and needs that full catalog (see _isPagedBrowseMode).
    final pagedAsync = ref.watch(pagedDealsProvider);
    final displayDeals = isPagedBrowseMode
        ? const <Deal>[]
        : ref.watch(filteredDealsProvider);
    final bool isInitialLoading;
    final bool hasLoadError;
    final Object? loadError;
    final bool feedIsEmpty;
    if (isPagedBrowseMode) {
      isInitialLoading = pagedAsync.isLoading && !pagedAsync.hasValue;
      hasLoadError = pagedAsync.hasError && !pagedAsync.hasValue;
      loadError = pagedAsync.error;
      feedIsEmpty =
          !isInitialLoading &&
          !hasLoadError &&
          (pagedAsync.value?.totalCount ?? 0) == 0;
    } else {
      final dealFeedAsync = ref.watch(dealFeedProvider);
      isInitialLoading = dealFeedAsync.isLoading && !dealFeedAsync.hasValue;
      hasLoadError = dealFeedAsync.hasError && !dealFeedAsync.hasValue;
      loadError = dealFeedAsync.error;
      feedIsEmpty =
          !isInitialLoading &&
          !hasLoadError &&
          (dealFeedAsync.asData?.value ?? []).isEmpty;
    }

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): _ScrollDownIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): _ScrollUpIntent(),
      },
      child: Actions(
        actions: {
          _ScrollDownIntent: CallbackAction<_ScrollDownIntent>(
            onInvoke: (_) => _scrollByArrowKey(80),
          ),
          _ScrollUpIntent: CallbackAction<_ScrollUpIntent>(
            onInvoke: (_) => _scrollByArrowKey(-80),
          ),
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // The app-level top nav bar (adaptive_scaffold.dart) already covers
          // logo/tabs/categories/search/auth on wide screens, so the feed's own
          // header is only needed on narrow/mobile screens (no top nav bar
          // there). Refresh lives in the floating button below instead of a
          // toolbar row on either layout.
          appBar: isWide ? null : const GlassStickyHeader(),
          // No background decoration here — the app shell (adaptive_scaffold.dart)
          // already paints one continuous gradient behind the top nav bar and
          // this page's content together. Painting a second, independent
          // gradient here (as this used to) restarts the color ramp from scratch
          // right at this page's own top edge, which reads as a hard seam/line
          // directly under the nav bar.
          body: Column(
            children: [
              // ─── Main Content ──────────────────────────────────────────────────
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
                                // glass pill (plus the "Live Market Price
                                // Tracker" hero headline above it) floating
                                // directly on the page's background gradient —
                                // top inset here is deliberately tight, just
                                // enough breathing room under the nav bar. ----
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    _heroHorizontalPadding(context),
                                    16,
                                    _heroHorizontalPadding(context),
                                    0,
                                  ),
                                  sliver: const SliverToBoxAdapter(
                                    child: BannerGlowBackdrop(
                                      child: LiveStatusBanner(),
                                    ),
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
                                          child: SizedBox(height: 8),
                                        ),
                                        RecentlyViewedSliver(),
                                      ],
                                    ),
                                  ),

                                // ---- Hero surface: a large, centered
                                // (max-width 1200) gradient-glass panel housing
                                // the core deal feed — Insane Deals, Biggest
                                // Price Drops, and the main grid. ----
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
                                        if (filters.searchQuery.isEmpty &&
                                            !filters.showFavoritesOnly)
                                          const TrendingDropsSliver(),
                                        const SliverToBoxAdapter(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              20,
                                              16,
                                              20,
                                              0,
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: SortDropdown(),
                                            ),
                                          ),
                                        ),
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
                                  child: AppFooter(
                                    onShopCategoryTap: _onFooterShopTap,
                                  ),
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
                                ref
                                    .read(searchHistoryProvider.notifier)
                                    .add(query);

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
      ),
    );
  }
}

// ─── Shimmer skeleton loading ─────────────────────────────────────────────────

// ─── Empty / Error states ─────────────────────────────────────────────────────

// ─── Top glass nav bar (desktop/tablet) ────────────────────────────────────────
//
// Replaces the old sidebar with a sticky, centered, floating "Liquid Glass"
// pill bar per the design system: logo, the Feed/Alerts switcher, the
// Categories dropdown (where the Settings tab used to sit — Settings now
// lives behind the profile/auth icon instead), the search field (Feed tab
// only), and the auth icon, living above every page rather than beside it.
// Lives here (alongside FeedPage) rather than in adaptive_scaffold.dart so
// the feed's own header and the app-shell nav bar it sits under are defined
// and styled in one place instead of two.

/// Top-level nav destinations — shared by the top glass nav bar and the
/// mobile bottom nav bar (adaptive_scaffold.dart). Settings lives behind the
/// profile/auth icon instead of being a primary destination here. Index 1 is
/// always Alerts (both call sites rely on this for the unread badge, rather
/// than comparing the now-localized label text).
List<(String, IconData, IconData)> navDestinations(AppLocalizations l10n) => [
  (l10n.navFeed, Icons.storefront_outlined, Icons.storefront),
  (l10n.navAlerts, Icons.notifications_outlined, Icons.notifications),
];

class GlassTopNavBar extends ConsumerWidget {
  const GlassTopNavBar({
    super.key,
    required this.selectedIndex,
    required this.unreadAlerts,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final int unreadAlerts;
  final void Function(int) onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = ref.watch(searchControllerProvider);
    final searchFocusNode = ref.watch(searchFocusNodeProvider);
    final isFeedTab = selectedIndex == 0;
    final l10n = AppLocalizations.of(context)!;
    final destinations = navDestinations(l10n);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GlassContainer(
            borderRadius: 32,
            enableHoverAnimation: false,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                const AppLogo(iconSize: 28, fontSize: 21),
                const SizedBox(width: 32),
                for (int i = 0; i < destinations.length; i++)
                  _TopNavItem(
                    label: destinations[i].$1,
                    icon: destinations[i].$2,
                    selectedIcon: destinations[i].$3,
                    selected: selectedIndex == i,
                    badgeCount: i == 1 ? unreadAlerts : 0,
                    onTap: () => onDestinationSelected(i),
                  ),
                const SizedBox(width: 4),
                GlassCategoriesMenu(
                  onCategorySelected: (_) {
                    // Picking a category only means something on the
                    // Feed tab, so jump there if we're elsewhere.
                    if (!isFeedTab) onDestinationSelected(0);
                  },
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: isFeedTab
                      ? GlassSearchField(
                          controller: searchController,
                          focusNode: searchFocusNode,
                          onChanged: (value) => handleSearchChanged(ref, value),
                          height: 44,
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 20),
                const _TopNavAuthIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNavItem extends StatelessWidget {
  const _TopNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    required this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  static const _selectedColor = Color(0xFF00B4FF);
  static const _unselectedColor = Color(0xFF8A8AA0);
  static const _pillRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    // A newly-triggered, not-yet-seen alert takes over this item's look —
    // spinning rainbow border, pulsing green bell + label — until the user
    // opens the Alerts tab (see FiredAlertsNotifier.markAllSeen).
    final pulsing = label == 'Alerts' && badgeCount > 0;

    if (pulsing) {
      return _PulsingAlertItem(
        label: label,
        icon: selected ? selectedIcon : icon,
        badgeCount: badgeCount,
        borderRadius: _pillRadius,
        selected: selected,
        onTap: onTap,
      );
    }

    final color = selected ? _selectedColor : _unselectedColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_pillRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1E2035) : Colors.transparent,
              borderRadius: BorderRadius.circular(_pillRadius),
              border: selected
                  ? Border.all(color: GlassColors.glowBorderHover)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selected ? selectedIcon : icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The "Alerts" nav pill's look while it has an unseen triggered price
/// alert: a rainbow ring spins around the border and the bell + label pulse
/// green, both driven off one repeating animation so they stay in sync.
class _PulsingAlertItem extends StatefulWidget {
  const _PulsingAlertItem({
    required this.label,
    required this.icon,
    required this.badgeCount,
    required this.borderRadius,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int badgeCount;
  final double borderRadius;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_PulsingAlertItem> createState() => _PulsingAlertItemState();
}

class _PulsingAlertItemState extends State<_PulsingAlertItem>
    with SingleTickerProviderStateMixin {
  static const _idleGreen = Color(0xFF1B4D3E);
  static const _pulseGreen = Color(0xFF00E676);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final pulse = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;
              final glowColor = Color.lerp(_idleGreen, _pulseGreen, pulse)!;
              return CustomPaint(
                foregroundPainter: _SpinningRainbowBorderPainter(
                  rotation: _controller.value * 2 * math.pi,
                  borderRadius: widget.borderRadius,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? const Color(0xFF1E2035)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: 1 + pulse * 0.18,
                        child: Badge(
                          label: Text(widget.badgeCount.toString()),
                          backgroundColor: _pulseGreen,
                          child: Icon(widget.icon, color: glowColor, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: glowColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Paints a rounded-rect ring stroke whose hue sweeps continuously as
/// [rotation] advances, giving the "spinning rainbow border" effect.
class _SpinningRainbowBorderPainter extends CustomPainter {
  _SpinningRainbowBorderPainter({
    required this.rotation,
    required this.borderRadius,
  });

  final double rotation;
  final double borderRadius;

  static const _colors = [
    Color(0xFFFF3B30),
    Color(0xFFFF9500),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFF00E676),
    Color(0xFF00B4FF),
    Color(0xFF5E5CE6),
    Color(0xFFFF2D95),
    Color(0xFFFF3B30),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(borderRadius),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        colors: _colors,
        transform: GradientRotation(rotation),
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _SpinningRainbowBorderPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}

class _TopNavAuthIcon extends ConsumerWidget {
  const _TopNavAuthIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return authState.when(
      data: (user) => IconButton(
        tooltip: user != null ? 'Profile' : 'Sign In',
        icon: Icon(
          user != null ? Icons.account_circle : Icons.person_outline,
          color: Colors.white,
        ),
        onPressed: () async {
          if (user != null) {
            await settings_lib.loadLibrary();
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => settings_lib.SettingsPage(),
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
      loading: () => const SizedBox(width: 48),
      error: (e, s) => const Icon(Icons.error, color: Colors.white),
    );
  }
}
