import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../features/auth/providers/auth_provider.dart';
import '../../../providers/repositories.dart';
import '../domain/price_alert.dart';

part 'alerts_provider.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
class AlertsNotifier extends _$AlertsNotifier {
  @override
  Future<List<PriceAlert>> build() async {
    final user = ref.watch(authNotifierProvider);
    if (user == null) return [];
    return ref.read(firestoreAlertRepositoryProvider).getAll(user.uid);
  }

  Future<void> add({
    required String title,
    required double targetPrice,
    required String displayCurrency,
    String? dealId,
    String? searchQuery,
  }) async {
    final user = ref.read(authNotifierProvider);
    if (user == null) return;

    final alert = PriceAlert(
      id: _uuid.v4(),
      title: title,
      targetPrice: targetPrice,
      displayCurrency: displayCurrency,
      dealId: dealId,
      searchQuery: searchQuery,
      createdAt: DateTime.now(),
    );
    await ref.read(firestoreAlertRepositoryProvider).save(user.uid, alert);
    state = AsyncData([alert, ...?state.valueOrNull]);
  }

  Future<void> remove(String id) async {
    final user = ref.read(authNotifierProvider);
    if (user == null) return;
    await ref.read(firestoreAlertRepositoryProvider).delete(user.uid, id);
    state = AsyncData(
      (state.valueOrNull ?? []).where((a) => a.id != id).toList(),
    );
  }

  Future<void> markTriggered(String id) async {
    final user = ref.read(authNotifierProvider);
    if (user == null) return;
    final current = state.valueOrNull ?? [];
    final index = current.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final updated = current[index].copyWith(isTriggered: true);
    await ref
        .read(firestoreAlertRepositoryProvider)
        .markTriggered(user.uid, id);
    state = AsyncData([...current]..[index] = updated);
  }
}
