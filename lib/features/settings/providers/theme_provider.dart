import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { system, light, dark, amoled }

final themeProvider = NotifierProvider<ThemeNotifier, AppTheme>(
  () => ThemeNotifier(),
);

class ThemeNotifier extends Notifier<AppTheme> {
  static const _key = 'app_theme_pref';

  @override
  AppTheme build() {
    _loadPref();
    return AppTheme.system;
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key);
    if (index != null && index >= 0 && index < AppTheme.values.length) {
      state = AppTheme.values[index];
    }
  }

  Future<void> updateTheme(AppTheme mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }
}
