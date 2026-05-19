import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../providers/repositories.dart';
import '../domain/price_alert.dart';

part 'alerts_provider.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
class AlertsNotifier extends _$AlertsNotifier {
  @override
  List<PriceAlert> build() => ref.read(alertRepositoryProvider).getAll();

  Future<void> add({
    required String title,
    required double targetPrice,
    required String displayCurrency,
    String? dealId,
    String? searchQuery,
  }) async {
    final alert = PriceAlert(
      id: _uuid.v4(),
      title: title,
      targetPrice: targetPrice,
      displayCurrency: displayCurrency,
      dealId: dealId,
      searchQuery: searchQuery,
      createdAt: DateTime.now(),
    );
    await ref.read(alertRepositoryProvider).save(alert);
    state = [alert, ...state];
  }

  Future<void> remove(String id) async {
    await ref.read(alertRepositoryProvider).delete(id);
    state = state.where((a) => a.id != id).toList();
  }

  Future<void> markTriggered(String id) async {
    final index = state.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final updated = state[index].copyWith(isTriggered: true);
    await ref.read(alertRepositoryProvider).save(updated);
    state = [...state]..[index] = updated;
  }
}
