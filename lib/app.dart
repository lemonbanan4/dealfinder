import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'widgets/adaptive_scaffold.dart';
import 'features/settings/providers/theme_provider.dart';
import 'services/notification/fcm_service.dart';

class PrisPulsApp extends ConsumerStatefulWidget {
  const PrisPulsApp({super.key});

  @override
  ConsumerState<PrisPulsApp> createState() => _PrisPulsAppState();
}

class _PrisPulsAppState extends ConsumerState<PrisPulsApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clearBadge();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clearBadge();
    }
  }

  Future<void> _clearBadge() async {
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      FlutterAppBadger.removeBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(themeProvider);

    final themeMode = switch (appTheme) {
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
      AppTheme.amoled => ThemeMode.dark,
      AppTheme.system => ThemeMode.system,
    };

    final isAmoled = appTheme == AppTheme.amoled;

    return MaterialApp(
      title: 'PrisPuls',
      navigatorKey: FCMService.navigatorKey,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006EFF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006EFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: isAmoled
            ? Colors.black
            : const Color(0xFF0A0B10),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
