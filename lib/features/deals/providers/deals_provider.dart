import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/repositories.dart';
import '../../../services/currency_converter.dart';
import '../domain/deal.dart';

part 'deals_provider.g.dart';

@Riverpod(keepAlive: true)
class DealFeedNotifier extends _$DealFeedNotifier {
  @override
  Future<List<Deal>> build() async {
    return ref.read(dealRepositoryProvider).getAll();
  }

  /// Scrapes all enabled sources and persists the merged results.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_scrapeAll);
  }

  Future<List<Deal>> _scrapeAll() async {
    final configs = ref
        .read(dealRepositoryProvider)
        .getConfigs()
        .where((c) => c.isEnabled)
        .toList();

    if (configs.isEmpty) {
      return ref.read(dealRepositoryProvider).getAll();
    }

    final service = ref.read(scraperServiceProvider);
    final settled = await Future.wait<List<Deal>>([
      for (final c in configs)
        service
            .scrape(c)
            .catchError((Object e, StackTrace s) => <Deal>[]),
    ]);

    final merged = _deduplicate(settled.expand((l) => l).toList());
    await ref.read(dealRepositoryProvider).saveAll(merged);
    return merged;
  }

  List<Deal> _deduplicate(List<Deal> deals) {
    final seen = <String>{};
    return deals.where((d) => seen.add(d.url)).toList()
      ..sort((a, b) => CurrencyConverter.toEur(a.currentPrice, a.currency)
            .compareTo(CurrencyConverter.toEur(b.currentPrice, b.currency)));
  }
}

/// Live stream of deals from Firestore — auto-updates when the collection
/// changes. FeedPage uses this as its primary data source.
final firestoreDealFeedProvider = StreamProvider<List<Deal>>((ref) {
  return ref.read(firestoreDealRepositoryProvider).watchAll();
});
