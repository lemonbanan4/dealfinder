import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/adaptive_scaffold.dart';
import 'features/deals/presentation/brand_landing_page.dart';
import 'features/deals/presentation/feed_page.dart' show regionProvider;
import 'features/deals/presentation/product_page.dart';
import 'services/notification/fcm_service.dart';
import 'features/settings/providers/cookie_consent_provider.dart';
import 'services/analytics_service.dart';
import 'theme/glass_colors.dart';
import 'l10n/app_localizations.dart';

/// Top-level routes. `/` is the existing AppShell (Feed/Alerts tabs,
/// Settings/Login/Legal all still reached via imperative Navigator.push
/// from within it — unchanged, go_router coexists fine with that for
/// navigation that doesn't need its own URL). `/brands/:slug` and
/// `/products/:id` are real routes for SEO landing pages (see
/// BrandLandingPage/ProductPage) — the whole reason this app needed real
/// path-based routing at all, since a Firebase Hosting rewrite rule (or a
/// search crawler) can only ever see the request path, never Flutter's
/// previous in-memory-only navigation.
final _router = GoRouter(
  navigatorKey: FCMService.navigatorKey,
  observers: [
    if (AnalyticsService().isEnabled)
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AppShell()),
    GoRoute(
      path: '/brands/:slug',
      builder: (context, state) =>
          BrandLandingPage(slug: state.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) => ProductPage(id: state.pathParameters['id']!),
    ),
  ],
);

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

    return MaterialApp.router(
      title: 'PrisPuls',
      scrollBehavior: _AppScrollBehavior(),
      routerConfig: _router,
      locale: _localeForRegion(region),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Dark-mode only by design (see CLAUDE.md's Design System) — the
      // whole Liquid Glass aesthetic (GlassColors, backdrop blur, navy
      // translucent fills) is built for a dark backdrop only, so there's
      // no light ThemeData to switch to and no user-facing theme picker
      // (it used to exist in Settings; removed for overflowing its row and
      // for offering variants — Light/Amoled — this app was never actually
      // designed to support).
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
        ),
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: GlassColors.purple500,
              brightness: Brightness.dark,
            ).copyWith(
              surface: GlassColors.background,
              surfaceContainer: GlassColors.surface,
              outlineVariant: GlassColors.glowBorder,
            ),
        scaffoldBackgroundColor: GlassColors.background,
        textTheme: _appTextTheme.apply(
          bodyColor: GlassColors.textBody,
          displayColor: GlassColors.textHeading,
        ),
        useMaterial3: true,
      ),
    );
  }
}
