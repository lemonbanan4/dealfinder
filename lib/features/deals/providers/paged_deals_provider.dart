import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/deal.dart';
import '../presentation/feed_page.dart' show feedFiltersProvider, regionProvider;

part 'paged_deals_provider.g.dart';

/// Cards per grid page — shared by the server-paginated default browse mode
/// ([pagedDealsProvider]) and the client-side pagination applied to
/// search/category/favorites results (see `filteredDealsPageProvider`), so
/// the page-size and Prev/Next controls behave identically either way.
const dealsPageSize = 24;

/// The feed grid's current 1-indexed page. Resets to 1 whenever the region
/// or any filter changes — a new search/category/region should always start
/// from the top, since a page number from the old result set may no longer
/// exist (or mean something different) in the new one.
@riverpod
class FeedPageIndex extends _$FeedPageIndex {
  @override
  int build() {
    ref.watch(regionProvider);
    ref.watch(feedFiltersProvider);
    return 1;
  }

  void setPage(int page) {
    state = page < 1 ? 1 : page;
  }
}

@immutable
class PagedDealsResult {
  const PagedDealsResult({
    required this.items,
    required this.totalCount,
    required this.totalPages,
  });

  final List<Deal> items;
  final int totalCount;
  final int totalPages;
}

/// Server-side paginated fetch of a single grid page, used for the default
/// browse state (no active search/category/favorites filter — see
/// `_isPagedBrowseMode` in feed_page.dart). Filtered views instead paginate
/// client-side over the full, already-fetched catalog (`dealFeedProvider`),
/// since category/favorites matching is client-only logic the API doesn't
/// know how to apply.
@riverpod
Future<PagedDealsResult> pagedDeals(Ref ref) async {
  final region = ref.watch(regionProvider);
  final page = ref.watch(feedPageIndexProvider);
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  final uri = Uri.parse(
    'https://dealfinder-swr5.onrender.com/api/products'
    '?region=$region&page=$page&limit=$dealsPageSize&t=$timestamp',
  );
  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Failed to load deals: ${response.statusCode}');
  }

  final data = json.decode(response.body) as Map<String, dynamic>;
  final items = (data['items'] as List<dynamic>)
      .map((json) => Deal.fromJson(json as Map<String, dynamic>))
      .toList();

  return PagedDealsResult(
    items: items,
    totalCount: data['total_count'] as int,
    totalPages: data['total_pages'] as int,
  );
}
