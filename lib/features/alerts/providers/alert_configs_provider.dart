import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_page.dart';
import '../data/alert_repository.dart';
import '../domain/alert_config.dart';

final alertRepositoryProvider = Provider((ref) => AlertRepository());

final alertConfigsProvider = StreamProvider<List<AlertConfig>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(alertRepositoryProvider).watchAlertConfigs();
});
