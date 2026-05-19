// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  displayCurrency: json['displayCurrency'] as String? ?? 'NOK',
  enabledSourceIds:
      (json['enabledSourceIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  refreshIntervalMinutes:
      (json['refreshIntervalMinutes'] as num?)?.toInt() ?? 30,
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'displayCurrency': instance.displayCurrency,
      'enabledSourceIds': instance.enabledSourceIds,
      'refreshIntervalMinutes': instance.refreshIntervalMinutes,
      'notificationsEnabled': instance.notificationsEnabled,
    };
