import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/repositories.dart';
import '../domain/app_settings.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> setDisplayCurrency(String currency) =>
      _update(state.copyWith(displayCurrency: currency));

  Future<void> setRefreshInterval(int minutes) =>
      _update(state.copyWith(refreshIntervalMinutes: minutes));

  Future<void> toggleNotifications({required bool enabled}) =>
      _update(state.copyWith(notificationsEnabled: enabled));

  Future<void> toggleSource(String sourceId, {required bool enabled}) {
    final ids = List<String>.from(state.enabledSourceIds);
    enabled ? ids.add(sourceId) : ids.remove(sourceId);
    return _update(state.copyWith(enabledSourceIds: ids));
  }

  Future<void> _update(AppSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }
}
