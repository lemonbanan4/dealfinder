import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/providers/auth_provider.dart';

/// A provider that holds the current theme mode of the app.
///
/// It is a [StateNotifierProvider] that reads from and writes to
/// [SharedPreferences] to persist the user's theme choice.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).value;
  return ThemeModeNotifier(sharedPreferences);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(_loadTheme(_prefs));

  final SharedPreferences? _prefs;
  static const _themeKey = 'themeMode';

  static ThemeMode _loadTheme(SharedPreferences? prefs) {
    if (prefs == null) return ThemeMode.system;
    // Get the stored index, defaulting to system (index 2) if not found.
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      return ThemeMode.values[themeIndex];
    }
    return ThemeMode.system;
  }

  /// Toggles the theme between light and dark mode and persists the choice.
  Future<void> toggle(bool isDark) async {
    final newTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    state = newTheme;
    await _prefs?.setInt(_themeKey, newTheme.index);
  }
}
