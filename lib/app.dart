import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter/foundation.dart';

import 'widgets/adaptive_scaffold.dart';
import 'features/settings/providers/theme_provider.dart';
import 'services/notification/fcm_service.dart';
import 'features/settings/providers/cookie_consent_provider.dart';
import 'services/analytics_service.dart';
import 'theme/glass_colors.dart';

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

    // Listen to cookie consent changes to enable/disable analytics.
    // This is a safe way to handle side effects in response to provider changes.
    if (kIsWeb) {
      ref.listen<CookieConsent>(cookieConsentProvider, (_, next) {
        final analyticsService = AnalyticsService();
        if (next == CookieConsent.accepted) {
          analyticsService.enableAnalytics();
        } else {
          // This handles the 'declined' and 'unknown' states.
          analyticsService.disableAnalytics();
        }
      });
    }

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
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006EFF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
        ),
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF006EFF),
              brightness: Brightness.dark,
            ).copyWith(
              surface: GlassColors.background,
              surfaceContainer: GlassColors.surface,
              outlineVariant: GlassColors.glowBorder,
            ),
        scaffoldBackgroundColor: isAmoled
            ? Colors.black
            : GlassColors.background,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      navigatorObservers: [
        if (AnalyticsService().isEnabled)
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      home: const AppShell(),
    );
  }
}
