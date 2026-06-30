import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/alert_repository.dart';
import '../domain/alert_config.dart';

final alertRepositoryProvider = Provider((ref) => AlertRepository());

final alertConfigsProvider = StreamProvider<List<AlertConfig>>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.watch(alertRepositoryProvider).watchAlertConfigs();
    },
    error: (e, s) => Stream.value([]),
    loading: () => Stream.value([]),
  );
});
