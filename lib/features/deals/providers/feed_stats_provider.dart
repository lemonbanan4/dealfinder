import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants.dart';
import '../presentation/feed_page.dart' show regionProvider;

part 'feed_stats_provider.g.dart';

@immutable
class FeedStats {
  const FeedStats({
    required this.priceDropsToday,
    required this.updatedLastSync,
  });

  final int priceDropsToday;
  final int updatedLastSync;
}

/// Aggregate counts (see `/api/stats` in api.py) driving the feed's live
/// status banner — how many products have a lower price than 24h ago, and
/// how many rows the most recent scraper run touched.
@riverpod
Future<FeedStats> feedStats(Ref ref) async {
  final region = ref.watch(regionProvider);
  final uri = Uri.parse('${ApiUrls.apiUrl}/api/stats?region=$region');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Failed to load feed stats: ${response.statusCode}');
  }

  final data = json.decode(response.body) as Map<String, dynamic>;
  return FeedStats(
    priceDropsToday: data['price_drops_today'] as int,
    updatedLastSync: data['updated_last_sync'] as int,
  );
}
