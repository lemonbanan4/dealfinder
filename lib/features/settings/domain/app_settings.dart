import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default('NOK') String displayCurrency,
    @Default([]) List<String> enabledSourceIds,
    @Default(30) int refreshIntervalMinutes,
    @Default(true) bool notificationsEnabled,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
