import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/repositories.dart';
import '../domain/deal.dart';

part 'deals_provider.g.dart';

@Riverpod(keepAlive: true)
class DealFeedNotifier extends _$DealFeedNotifier {
  @override
  AsyncValue<List<Deal>> build() {
    // Scraper integration added in Phase 3.
    final cached = ref.read(dealRepositoryProvider).getAll();
    return AsyncData(cached);
  }

  Future<void> refresh() async {
    // Phase 3: invoke ScraperService here.
    state = AsyncData(ref.read(dealRepositoryProvider).getAll());
  }
}
