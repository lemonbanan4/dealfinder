import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/repositories.dart';
import '../domain/scraper_config.dart';

part 'scraper_configs_provider.g.dart';

@Riverpod(keepAlive: true)
class ScraperConfigsNotifier extends _$ScraperConfigsNotifier {
  @override
  List<ScraperConfig> build() =>
      ref.read(dealRepositoryProvider).getConfigs();

  Future<void> toggle(String id, {required bool enabled}) async {
    final index = state.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final updated = state[index].copyWith(isEnabled: enabled);
    await ref.read(dealRepositoryProvider).saveConfig(updated);
    state = [...state]..[index] = updated;
  }

  Future<void> saveConfig(ScraperConfig config) async {
    await ref.read(dealRepositoryProvider).saveConfig(config);
    final index = state.indexWhere((c) => c.id == config.id);
    if (index == -1) {
      state = [...state, config];
    } else {
      state = [...state]..[index] = config;
    }
  }

  Future<void> deleteConfig(String id) async {
    await ref.read(dealRepositoryProvider).deleteConfig(id);
    state = state.where((c) => c.id != id).toList();
  }
}
