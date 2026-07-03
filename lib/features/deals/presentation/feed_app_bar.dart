import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/login_page.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/presentation/settings_page.dart';
import 'feed_page.dart';
import '../providers/deals_provider.dart';
import '../providers/favorites_provider.dart';

class FeedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const FeedAppBar({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final ValueNotifier<bool> isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final filters = ref.watch(feedFiltersProvider);
    final favorites = ref.watch(favoritesProvider);
    final isGrid = ref.watch(feedViewModeProvider);
    final region = ref.watch(regionProvider);
    final categoryList = ref.watch(categoriesProvider);

    return AppBar(
      title: const Text('DealFinder'),
      actions: [
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
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
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
          valueListenable: isRefreshing,
          builder: (context, isRefreshing, _) => IconButton(
            tooltip: 'Refresh',
            onPressed: isRefreshing ? null : onRefresh,
            icon: isRefreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ),
        IconButton(
          tooltip: filters.showFavoritesOnly ? 'Show All' : 'Show Favorites',
          icon: Badge(
            isLabelVisible: favorites.value?.isNotEmpty ?? false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              filters.showFavoritesOnly
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
          color: filters.showFavoritesOnly
              ? Theme.of(context).colorScheme.error
              : null,
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
            ref.read(regionProvider.notifier).setRegion(value);
            ref.read(dealFeedProvider.notifier).refresh();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'se', child: Text('🇸🇪 Sweden')),
            PopupMenuItem(value: 'no', child: Text('🇳🇴 Norway')),
          ],
        ),
        PopupMenuButton<String>(
          icon: Badge(
            isLabelVisible: filters.category != 'All',
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.filter_list),
          ),
          tooltip: 'Filter by Category',
          initialValue: filters.category,
          onSelected: (value) =>
              ref.read(feedFiltersProvider.notifier).updateCategory(value),
          itemBuilder: (_) => [
            for (final cat in categoryList)
              PopupMenuItem(value: cat, child: Text(formatSourceName(cat))),
          ],
        ),
        PopupMenuButton<ProductSort>(
          icon: Badge(
            isLabelVisible: filters.sort != ProductSort.none,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.sort),
          ),
          tooltip: 'Sort products',
          initialValue: filters.sort,
          onSelected: (value) =>
              ref.read(feedFiltersProvider.notifier).updateSort(value),
          itemBuilder: (_) => const [
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
            PopupMenuItem(
              value: ProductSort.discountDesc,
              child: Text('Biggest Discount'),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
