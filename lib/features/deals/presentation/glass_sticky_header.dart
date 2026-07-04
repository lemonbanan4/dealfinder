import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/glass_colors.dart';
import '../../../widgets/app_logo.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/presentation/settings_page.dart';
import '../providers/deals_provider.dart';
import '../providers/favorites_provider.dart';
import 'feed_page.dart';
import 'glass_categories_menu.dart';
import 'glass_search_field.dart';

/// The feed's own "Liquid Glass" toolbar: the feed-specific controls (sort,
/// region, favorites, view toggle, refresh).
///
/// On wide screens this sits directly below the app-level `_GlassTopNavBar`
/// (logo, Feed/Alerts switcher, Categories dropdown, search field, auth icon
/// — see adaptive_scaffold.dart), so it doesn't repeat those. On
/// narrow/mobile screens there is no top nav bar (mobile uses a bottom
/// NavigationBar instead), so this keeps its own logo, Categories dropdown,
/// search field, and auth icon.
class GlassStickyHeader extends ConsumerWidget implements PreferredSizeWidget {
  const GlassStickyHeader({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final ValueNotifier<bool> isRefreshing;
  final VoidCallback onRefresh;

  @override
  Size get preferredSize => const Size.fromHeight(116);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final searchController = ref.watch(searchControllerProvider);
    final searchFocusNode = ref.watch(searchFocusNodeProvider);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(11, 14, 20, 0.82),
            border: Border(bottom: BorderSide(color: GlassColors.glowBorder)),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            isWide ? 12 : MediaQuery.paddingOf(context).top + 8,
            16,
            12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (!isWide) ...[const AppLogo(), const SizedBox(width: 12)],
                      const Spacer(),
                      if (isWide) ..._wideActions(context, ref) else _CompactOverflowMenu(),
                      if (!isWide) ...[const SizedBox(width: 4), const _AuthIcon()],
                    ],
                  ),
                  if (!isWide) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const GlassCategoriesMenu(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GlassSearchField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            onChanged: (value) => handleSearchChanged(ref, value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _wideActions(BuildContext context, WidgetRef ref) {
    return [
      _RegionButton(),
      _SortButton(),
      _FavoritesToggle(),
      _ViewToggle(),
      _RefreshButton(isRefreshing: isRefreshing, onRefresh: onRefresh),
    ];
  }
}


// ─── Auth / profile icon ───────────────────────────────────────────────────────

class _AuthIcon extends ConsumerWidget {
  const _AuthIcon();

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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  user != null ? const SettingsPage() : const LoginPage(),
            ),
          );
        },
      ),
      loading: () => const SizedBox(width: 48),
      error: (e, s) => const Icon(Icons.error, color: Colors.white),
    );
  }
}

// ─── Secondary controls (region, sort, favorites, view toggle, refresh) ───────

class _RegionButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(regionProvider);
    return PopupMenuButton<String>(
      icon: Text(region == 'no' ? '🇳🇴' : '🇸🇪', style: const TextStyle(fontSize: 20)),
      tooltip: 'Select Region',
      onSelected: (value) {
        ref.read(regionProvider.notifier).setRegion(value);
        ref.read(dealFeedProvider.notifier).refresh();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'se', child: Text('🇸🇪 Sweden')),
        PopupMenuItem(value: 'no', child: Text('🇳🇴 Norway')),
      ],
    );
  }
}

class _SortButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(feedFiltersProvider);
    return PopupMenuButton<ProductSort>(
      icon: Badge(
        isLabelVisible: filters.sort != ProductSort.none,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.sort, color: Colors.white),
      ),
      tooltip: 'Sort products',
      initialValue: filters.sort,
      onSelected: (value) => ref.read(feedFiltersProvider.notifier).updateSort(value),
      itemBuilder: (_) => const [
        PopupMenuItem(value: ProductSort.none, child: Text('Default Sorting')),
        PopupMenuItem(value: ProductSort.priceAsc, child: Text('Price: Low to High')),
        PopupMenuItem(value: ProductSort.priceDesc, child: Text('Price: High to Low')),
        PopupMenuItem(value: ProductSort.discountDesc, child: Text('Biggest Discount')),
      ],
    );
  }
}

class _FavoritesToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(feedFiltersProvider);
    final favorites = ref.watch(favoritesProvider);
    return IconButton(
      tooltip: filters.showFavoritesOnly ? 'Show All' : 'Show Favorites',
      icon: Badge(
        isLabelVisible: favorites.value?.isNotEmpty ?? false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(filters.showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
      ),
      color: filters.showFavoritesOnly ? Theme.of(context).colorScheme.error : Colors.white,
      onPressed: () => ref.read(feedFiltersProvider.notifier).toggleFavoritesOnly(),
    );
  }
}

class _ViewToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = ref.watch(feedViewModeProvider);
    return IconButton(
      tooltip: isGrid ? 'List View' : 'Grid View',
      icon: Icon(isGrid ? Icons.view_list : Icons.grid_view, color: Colors.white),
      onPressed: () => ref.read(feedViewModeProvider.notifier).toggle(),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.isRefreshing, required this.onRefresh});

  final ValueNotifier<bool> isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isRefreshing,
      builder: (context, refreshing, _) => IconButton(
        tooltip: 'Refresh',
        onPressed: refreshing ? null : onRefresh,
        icon: refreshing
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}

/// Narrow-screen fallback: the same secondary actions tucked behind one
/// overflow button so the logo, categories dropdown, and auth icon always
/// have room to breathe on mobile widths.
class _CompactOverflowMenu extends ConsumerWidget {
  const _CompactOverflowMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(feedFiltersProvider);
    final region = ref.watch(regionProvider);
    final isGrid = ref.watch(feedViewModeProvider);

    return PopupMenuButton<VoidCallback>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      tooltip: 'More options',
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: () => ref.read(feedViewModeProvider.notifier).toggle(),
          child: ListTile(
            leading: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            title: Text(isGrid ? 'List View' : 'Grid View'),
          ),
        ),
        PopupMenuItem(
          value: () => ref.read(feedFiltersProvider.notifier).toggleFavoritesOnly(),
          child: ListTile(
            leading: Icon(filters.showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            title: Text(filters.showFavoritesOnly ? 'Show All' : 'Show Favorites'),
          ),
        ),
        PopupMenuItem(
          value: () {
            final next = region == 'no' ? 'se' : 'no';
            ref.read(regionProvider.notifier).setRegion(next);
            ref.read(dealFeedProvider.notifier).refresh();
          },
          child: ListTile(
            leading: Text(region == 'no' ? '🇳🇴' : '🇸🇪'),
            title: Text('Switch to ${region == 'no' ? 'Sweden' : 'Norway'}'),
          ),
        ),
        PopupMenuItem(
          value: () => ref.read(dealFeedProvider.notifier).refresh(),
          child: const ListTile(leading: Icon(Icons.refresh), title: Text('Refresh')),
        ),
      ],
    );
  }
}
