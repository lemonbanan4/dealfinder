import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/adaptive_scaffold.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/deals/presentation/feed_page.dart' show regionProvider;
import 'services/notification/fcm_service.dart';
import 'features/settings/providers/cookie_consent_provider.dart';
import 'services/analytics_service.dart';
import 'theme/glass_colors.dart';
import 'l10n/app_localizations.dart';

/// Maps the existing region signal (see `Region` in feed_page.dart — IP
/// geolocation, falling back to browser locale, with an explicit user
/// choice in Settings always winning) to a UI display language, so the
/// whole app — not just deal data — reads as Swedish/Norwegian rather than
/// defaulting to English. No separate language picker: region already
/// covers this, and having two independent controls that could disagree
/// (Swedish region + English UI) would be confusing.
Locale _localeForRegion(String region) => switch (region) {
  'no' => const Locale('nb'),
  _ => const Locale('sv'),
};

// Inter for body/label text, Space Grotesk for anything headline/title/
// display-level — matches the reference design's font pairing. Built once
// and reused by both the light and dark ThemeData below.
final _appTextTheme = GoogleFonts.interTextTheme().copyWith(
  displayLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
  displayMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
  displaySmall: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
  headlineLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
  headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
  headlineSmall: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
  titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
  titleMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500),
  titleSmall: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500),
);

// Flutter's default ScrollBehavior only treats touch/stylus pointers as
// drag-to-scroll gestures — a mouse click-and-drag on web/desktop is
// otherwise ignored (only the wheel/trackpad works). Add mouse so every
// scrollable in the app, including horizontal rows like Recently Viewed,
// can be click-dragged too.
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

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
    final region = ref.watch(regionProvider);

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
      scrollBehavior: _AppScrollBehavior(),
      navigatorKey: FCMService.navigatorKey,
      locale: _localeForRegion(region),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: themeMode,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: GlassColors.blue500,
          brightness: Brightness.light,
        ),
        textTheme: _appTextTheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
        ),
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: GlassColors.blue500,
              brightness: Brightness.dark,
            ).copyWith(
              surface: GlassColors.background,
              surfaceContainer: GlassColors.surface,
              outlineVariant: GlassColors.glowBorder,
            ),
        scaffoldBackgroundColor: isAmoled
            ? Colors.black
            : GlassColors.background,
        textTheme: _appTextTheme.apply(
          bodyColor: GlassColors.textBody,
          displayColor: GlassColors.textHeading,
        ),
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
