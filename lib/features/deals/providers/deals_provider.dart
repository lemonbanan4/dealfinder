import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import '../../../providers/repositories.dart';
import '../domain/deal.dart';
import '../presentation/feed_page.dart' show regionProvider;

part 'deals_provider.g.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

@Riverpod(keepAlive: true)
class DealFeedNotifier extends _$DealFeedNotifier {
  @override
  Future<List<Deal>> build() async {
    // Watch the region! When the region provider updates, this automatically refetches
    final region = ref.watch(regionProvider);
    return _fetchFromApi(region);
  }

  Future<List<Deal>> _fetchFromApi(String region) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(
        Uri.parse(
          'https://dealfinder-swr5.onrender.com/api/products?region=$region&t=$timestamp',
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final deals = data.map((json) => Deal.fromJson(json)).toList();
        // Save to local cache
        try {
          await ref.read(dealRepositoryProvider).saveAll(deals);
        } catch (e) {
          log('Failed to save deals to Hive cache: $e');
        }
        return deals;
      } else {
        throw Exception('Failed to load deals: ${response.statusCode}');
      }
    } catch (e, s) {
      log('Failed to fetch deals from API, attempting local cache fallback...', error: e, stackTrace: s);
      try {
        final cached = ref.read(dealRepositoryProvider).getAll();
        if (cached.isNotEmpty) {
          // Filter cached deals by region: either the legacy aggregate source
          // ('se'/'all_se') from older cached data, or a per-store source
          // like 'acer_se'/'samsung_no' (see scraper/scraper.py's per-store
          // StoreConfig ids, which all end in '_se'/'_no').
          final regionCode = region.toLowerCase();
          final filtered = cached.where((d) {
            final src = d.source.toLowerCase();
            return src == regionCode ||
                src == 'all_$regionCode' ||
                src.endsWith('_$regionCode');
          }).toList();
          if (filtered.isNotEmpty) {
            return filtered;
          }
        }
      } catch (cacheError) {
        log('Failed to read from local Hive cache: $cacheError');
      }
      // Re-throw the original error if fallback also has no data or fails
      Error.throwWithStackTrace(e, s);
    }
  }

  /// Refreshes the current list of deals
  Future<void> refresh() async {
    final region = ref.read(regionProvider);
    state = const AsyncValue.loading();
    try {
      final deals = await _fetchFromApi(region);
      state = AsyncValue.data(deals);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

/// Deals discounted ≥ 25 % off their original price, sorted deepest first.
final topDealsProvider = Provider<AsyncValue<List<Deal>>>((ref) {
  return ref.watch(dealFeedProvider).whenData((deals) {
    return deals.where((d) => (d.discountPercent ?? 0) >= 25).toList()..sort(
      (a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0),
    );
  });
});

@riverpod
Future<List<FlSpot>> priceHistoryProvider(Ref ref, String productId) async {
  final supabase = ref.watch(supabaseProvider);
  final response = await supabase
      .from('price_history')
      .select('price, recorded_at')
      .eq('product_id', productId)
      .order('recorded_at', ascending: true);

  final List<dynamic> list = response as List<dynamic>;
  return list.map((item) {
    final price = (item['price'] as num).toDouble();
    final recordedAt = DateTime.parse(item['recorded_at'] as String);
    final x = recordedAt.millisecondsSinceEpoch.toDouble();
    return FlSpot(x, price);
  }).toList();
}
