import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants.dart';
import '../domain/deal.dart';
import '../presentation/feed_page.dart' show regionProvider;

part 'trending_drops_provider.g.dart';

/// The 3 products with the biggest price drop over the last 24h (see
/// `/api/deals/biggest-drops` in api.py), used for the "Biggest Price Drops"
/// shelf. The endpoint returns the 24h-ago price under the same
/// `retail_price` JSON key /api/products uses for a product's list price, so
/// it decodes straight into [Deal] and its `discountPercent` getter reads as
/// the size of the drop with no extra plumbing.
@riverpod
Future<List<Deal>> trendingDrops(Ref ref) async {
  final region = ref.watch(regionProvider);
  final uri = Uri.parse(
    '${ApiUrls.apiUrl}/api/deals/biggest-drops?region=$region&limit=3',
  );
  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Failed to load biggest drops: ${response.statusCode}');
  }

  final data = json.decode(response.body) as Map<String, dynamic>;
  final items = data['items'] as List<dynamic>;
  return items
      .map((item) => Deal.fromJson(item as Map<String, dynamic>))
      .toList();
}
