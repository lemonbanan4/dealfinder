import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/deal.dart';
import '../presentation/feed_page.dart';
import 'favorites_provider.dart';
import 'deals_provider.dart';

part 'filtered_deals_provider.g.dart';

@riverpod
List<Deal> filteredDeals(Ref ref) {
  final filters = ref.watch(feedFiltersProvider);
  final deals = ref.watch(dealFeedProvider).asData?.value ?? [];
  final favorites = ref.watch(favoritesProvider).value ?? {};

  final displayDeals = deals.where((d) {
    if (filters.showFavoritesOnly && !favorites.contains(d.id)) {
      return false;
    }
    final q = filters.searchQuery.toLowerCase();
    return (d.title.toLowerCase().contains(q) ||
            d.source.toLowerCase().contains(q)) &&
        (filters.category == 'All' || d.source == filters.category);
  }).toList();

  // Apply the active sorting method
  switch (filters.sort) {
    case ProductSort.priceAsc:
      displayDeals.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
      break;
    case ProductSort.priceDesc:
      displayDeals.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
      break;
    case ProductSort.discountDesc:
      displayDeals.sort(
        (a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0),
      );
      break;
    case ProductSort.none:
      break;
  }
  return displayDeals;
}
