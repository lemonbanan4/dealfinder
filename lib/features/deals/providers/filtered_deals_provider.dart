import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/currency_converter.dart';
import '../domain/deal.dart';
import '../domain/product_category.dart';
import '../presentation/feed_page.dart';
import 'favorites_provider.dart';
import 'deals_provider.dart';
import 'paged_deals_provider.dart';

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
        (filters.category == 'All' || categoryForDeal(d) == filters.category);
  }).toList();

  // Apply the active sorting method. Deals span multiple currencies (SEK/NOK
  // stores mixed together), so comparing raw currentPrice would interleave
  // them nonsensically (100 NOK sorting "cheaper" than 90 SEK despite being
  // worth more) — normalize to EUR first, same as the dedup sort in
  // deals_provider.dart.
  switch (filters.sort) {
    case ProductSort.priceAsc:
      displayDeals.sort(
        (a, b) => CurrencyConverter.toEur(
          a.currentPrice,
          a.currency,
        ).compareTo(CurrencyConverter.toEur(b.currentPrice, b.currency)),
      );
      break;
    case ProductSort.priceDesc:
      displayDeals.sort(
        (a, b) => CurrencyConverter.toEur(
          b.currentPrice,
          b.currency,
        ).compareTo(CurrencyConverter.toEur(a.currentPrice, a.currency)),
      );
      break;
    case ProductSort.newest:
      displayDeals.sort(
        (a, b) => (b.lastUpdated ?? DateTime(0)).compareTo(
          a.lastUpdated ?? DateTime(0),
        ),
      );
      break;
    case ProductSort.none:
      break;
  }
  return displayDeals;
}

@immutable
class FilteredDealsPage {
  const FilteredDealsPage({required this.items, required this.totalPages});

  final List<Deal> items;
  final int totalPages;
}

/// Client-side pagination over [filteredDealsProvider] — used whenever a
/// search/category/favorites filter is active, since category matching is a
/// client-only heuristic (see `product_category.dart`) the API can't apply,
/// so the server can't paginate a filtered result set for us.
@riverpod
FilteredDealsPage filteredDealsPage(Ref ref) {
  final deals = ref.watch(filteredDealsProvider);
  final page = ref.watch(feedPageIndexProvider);
  final totalPages = deals.isEmpty ? 1 : (deals.length / dealsPageSize).ceil();

  final start = (page - 1) * dealsPageSize;
  if (start >= deals.length) {
    return FilteredDealsPage(items: const [], totalPages: totalPages);
  }
  final end = (start + dealsPageSize).clamp(0, deals.length);
  return FilteredDealsPage(items: deals.sublist(start, end), totalPages: totalPages);
}
