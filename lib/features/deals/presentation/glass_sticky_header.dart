import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/glass_colors.dart';
import '../../../widgets/app_logo.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/presentation/settings_page.dart';
import '../domain/product_category.dart';
import '../providers/deals_provider.dart';
import '../providers/favorites_provider.dart';
import 'feed_page.dart';

/// The app's single persistent "Liquid Glass" header: a blurred, glowing
/// glass panel pinned above the feed with an integrated search field, a
/// hover/click "Categories" dropdown, and the auth icon — replacing the
/// previous separate `FeedAppBar` + `FeedHeader` widgets.
class GlassStickyHeader extends ConsumerWidget implements PreferredSizeWidget {
  const GlassStickyHeader({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;
  final ValueNotifier<bool> isRefreshing;
  final VoidCallback onRefresh;

  @override
  Size get preferredSize => const Size.fromHeight(116);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(11, 14, 20, 0.82),
            border: Border(bottom: BorderSide(color: GlassColors.glowBorder)),
          ),
          padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const AppLogo(),
                  const SizedBox(width: 12),
                  if (isWide) const _CategoriesMenu(),
                  const Spacer(),
                  if (isWide) ..._wideActions(context, ref) else _CompactOverflowMenu(),
                  const SizedBox(width: 4),
                  const _AuthIcon(),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (!isWide) ...[const _CategoriesMenu(), const SizedBox(width: 8)],
                  Expanded(child: _SearchField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    onChanged: onSearchChanged,
                  )),
                ],
              ),
            ],
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

// ─── Search field ─────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: GlassColors.glowBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.search, color: Color(0xFF5A5A78)),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  cursorColor: const Color(0xFF00B4FF),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Search products or brands...',
                    hintStyle: TextStyle(color: Color(0xFF5A5A78)),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: onChanged,
                ),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF5A5A78)),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Categories dropdown (hover or click to open) ──────────────────────────────

class _CategoriesMenu extends ConsumerStatefulWidget {
  const _CategoriesMenu();

  @override
  ConsumerState<_CategoriesMenu> createState() => _CategoriesMenuState();
}

class _CategoriesMenuState extends ConsumerState<_CategoriesMenu> {
  final _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(feedFiltersProvider);
    final activeLabel = filters.category == 'All' ? 'Categories' : filters.category;

    return MenuAnchor(
      controller: _menuController,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          GlassColors.surface.withValues(alpha: 0.98),
        ),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        side: const WidgetStatePropertyAll(BorderSide(color: GlassColors.glowBorder)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: const WidgetStatePropertyAll(12),
      ),
      menuChildren: [
        for (final cat in dealCategories)
          MenuItemButton(
            onPressed: () =>
                ref.read(feedFiltersProvider.notifier).updateCategory(cat),
            leadingIcon: SizedBox(
              width: 18,
              child: filters.category == cat
                  ? const Icon(Icons.check, size: 18, color: Color(0xFF00B4FF))
                  : null,
            ),
            child: Text(cat),
          ),
      ],
      builder: (context, controller, child) {
        return MouseRegion(
          onEnter: (_) {
            if (!controller.isOpen) controller.open();
          },
          child: OutlinedButton.icon(
            onPressed: () => controller.isOpen ? controller.close() : controller.open(),
            icon: const Icon(Icons.category_outlined, size: 18),
            label: Text(activeLabel, overflow: TextOverflow.ellipsis),
            style: OutlinedButton.styleFrom(
              foregroundColor: filters.category != 'All'
                  ? const Color(0xFF00B4FF)
                  : Colors.white70,
              side: BorderSide(
                color: filters.category != 'All'
                    ? GlassColors.glowBorderHover
                    : GlassColors.glowBorder,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        );
      },
    );
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
