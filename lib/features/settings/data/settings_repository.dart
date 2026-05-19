import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants.dart';
import '../domain/app_settings.dart';

class SettingsRepository {
  static const _key = 'app_settings';

  Box<String> get _box => Hive.box<String>(HiveBoxes.settings);

  AppSettings load() {
    final raw = _box.get(_key);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(AppSettings settings) =>
      _box.put(_key, jsonEncode(settings.toJson()));
}
