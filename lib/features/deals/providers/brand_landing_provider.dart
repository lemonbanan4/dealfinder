import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../domain/deal.dart';

part 'brand_landing_provider.g.dart';

/// Deals for one brand landing page's store feed (see
/// `/api/deals/by-store` in api.py and `BrandLanding` in
/// `domain/brand_landing.dart`). Keyed by the exact `feed_region` value,
/// not the page slug, so it's a plain exact-match fetch with no guessing.
@riverpod
Future<List<Deal>> brandLandingDeals(Ref ref, String storeFeed) async {
  final response = await apiGet(
    '/api/deals/by-store',
    queryParameters: {'store': storeFeed, 'limit': '24'},
  );

  final data = json.decode(response.body) as Map<String, dynamic>;
  final items = data['items'] as List<dynamic>;
  return items
      .map((item) => Deal.fromJson(item as Map<String, dynamic>))
      .toList();
}
