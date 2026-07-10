import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../domain/deal.dart';
import '../domain/product_category.dart';
import '../presentation/feed_page.dart'
    show feedFiltersProvider, regionProvider;

part 'trending_drops_provider.g.dart';

/// Small shelf, so the default (no category filter) fetch only needs a
/// handful of candidates.
const _defaultDropsLimit = 3;

/// Category is a client-only title-keyword heuristic (see
/// `categoryForDeal`/`product_category.dart`) — there's no DB column for the
/// backend to filter on, so a category-scoped request instead asks for a
/// much larger candidate pool (still sorted biggest-drop-first) and filters
/// it down client-side.
const _categoryScopedDropsLimit = 100;

/// The biggest price drops over the last 24h (see `/api/deals/biggest-drops`
/// in api.py), used for the "Biggest Price Drops" shelf. The endpoint
/// returns the 24h-ago price under the same `retail_price` JSON key
/// /api/products uses for a product's list price, so it decodes straight
/// into [Deal] and its `discountPercent` getter reads as the size of the
/// drop with no extra plumbing.
///
/// When a category filter is active on the feed, this shelf follows it —
/// showing the biggest drops *within that category* rather than site-wide,
/// so picking "Audio" surfaces audio price drops instead of whatever's
/// dropped the most across the entire catalog.
@riverpod
Future<List<Deal>> trendingDrops(Ref ref) async {
  final region = ref.watch(regionProvider);
  final category = ref.watch(
    feedFiltersProvider.select((filters) => filters.category),
  );
  final isCategoryScoped = category != 'All';

  final response = await apiGet(
    '/api/deals/biggest-drops',
    queryParameters: {
      'region': region,
      'limit': isCategoryScoped
          ? '$_categoryScopedDropsLimit'
          : '$_defaultDropsLimit',
    },
  );

  final data = json.decode(response.body) as Map<String, dynamic>;
  final items = data['items'] as List<dynamic>;
  final deals = items
      .map((item) => Deal.fromJson(item as Map<String, dynamic>))
      .toList();

  if (!isCategoryScoped) return deals;
  return deals
      .where((deal) => categoryForDeal(deal) == category)
      .take(_defaultDropsLimit)
      .toList();
}
