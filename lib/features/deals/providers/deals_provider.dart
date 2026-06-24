import 'dart:async';
import 'dart:developer';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants.dart';
import '../../../providers/repositories.dart';
import '../../../services/currency_converter.dart';
import '../domain/deal.dart';
import 'scraper_configs_provider.dart';

part 'deals_provider.g.dart';

@Riverpod(keepAlive: true)
class DealFeedNotifier extends _$DealFeedNotifier {
  @override
  Future<List<Deal>> build() async {
    return _fetchFromApi();
  }

  Future<List<Deal>> _fetchFromApi() async {
    state = const AsyncValue.loading();
    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.apiUrl}/api/products'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final deals = data.map((json) => Deal.fromJson(json)).toList();
        state = AsyncValue.data(deals);
        return deals;
      } else {
        throw Exception('Failed to load deals');
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return [];
    }
  }

  /// Scrapes all enabled sources and writes results to Firestore.
  /// The stream subscription in [build] automatically pushes the updated
  /// list to the UI — no manual state assignment needed here.
  Future<void> refresh() async {
    await _fetchFromApi();
    await _scrapeAndSave();
  }

  Future<void> _scrapeAndSave() async {
    final configs = ref
        .read(scraperConfigsProvider)
        .where((c) => c.isEnabled)
        .toList();

    if (configs.isEmpty) return;

    final service = ref.read(scraperServiceProvider);
    final configsNotifier = ref.read(scraperConfigsProvider.notifier);

    final results = await Future.wait(
      configs.map((c) async {
        try {
          final deals = await service.scrape(c);
          if (c.lastError != null) {
            await configsNotifier.saveConfig(
              c.copyWith(lastError: null, lastErrorAt: null),
            );
          }
          return deals;
        } catch (e, s) {
          log(
            'Scraper failed for "${c.name}"',
            name: 'DealFeedNotifier',
            error: e,
            stackTrace: s,
          );
          await configsNotifier.saveConfig(
            c.copyWith(lastError: e.toString(), lastErrorAt: DateTime.now()),
          );
          return <Deal>[];
        }
      }),
    );

    final merged = _deduplicate(results.expand((l) => l).toList());
    await ref.read(dealRepositoryProvider).saveAll(merged);
  }

  List<Deal> _deduplicate(List<Deal> deals) {
    final seen = <String>{};
    return deals.where((d) => seen.add(d.url)).toList()..sort(
      (a, b) => CurrencyConverter.toEur(
        a.currentPrice,
        a.currency,
      ).compareTo(CurrencyConverter.toEur(b.currentPrice, b.currency)),
    );
  }
}

/// Deals discounted ≥ 25 % off their original price, sorted deepest first.
/// Mirrors the async state of [dealFeedProvider] — consumers get loading/error
/// for free by calling `.when` on the result.
final topDealsProvider = Provider<AsyncValue<List<Deal>>>((ref) {
  return ref.watch(dealFeedProvider).whenData((deals) {
    return deals.where((d) => (d.discountPercent ?? 0) >= 25).toList()..sort(
      (a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0),
    );
  });
});
