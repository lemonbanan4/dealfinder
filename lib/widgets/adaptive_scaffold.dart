import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

import '../features/alerts/presentation/alerts_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/deals/presentation/feed_page.dart';
import '../features/settings/providers/cookie_consent_provider.dart';
import 'cookie_consent_banner.dart';
import '../features/alerts/providers/fired_alerts_provider.dart';
import '../features/alerts/providers/unread_alerts_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/glass_colors.dart';

part 'adaptive_scaffold.g.dart';

const _pages = <Widget>[FeedPage(), AlertsPage()];

@riverpod
class AppShellIndex extends _$AppShellIndex {
  @override
  int build() => 0;

  Future<void> onDestinationSelected(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    // We added .value right here to check the actual user state!
    if (index == 1 && ref.read(authProvider).value == null) {
      final signedIn = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute<bool>(builder: (_) => const LoginPage()));
      if (signedIn == true) {
        state = 1;
        ref.read(firedAlertsProvider.notifier)
          ..start()
          ..markAllSeen();
      }
      return;
    }
    state = index;
    if (index == 1) {
      ref.read(firedAlertsProvider.notifier).markAllSeen();
    }
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      children: [
        Expanded(child: _AppShellMain()),
        CookieConsentBanner(),
      ],
    );
  }
}

class _AppShellMain extends ConsumerStatefulWidget {
  const _AppShellMain();

  @override
  ConsumerState<_AppShellMain> createState() => _AppShellMainState();
}

class _AppShellMainState extends ConsumerState<_AppShellMain> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(cookieConsentProvider.notifier).loadConsent(),
      );
    }
    ref.read(firedAlertsProvider.notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final unreadAlerts = ref.watch(unreadAlertsProvider);
    final selectedIndex = ref.watch(appShellIndexProvider);

    // The background is painted exactly once here, behind the nav bar AND
    // the page content together, so it reads as one continuous backdrop
    // rather than two separately-painted surfaces meeting at a seam. Pages
    // (FeedPage, AlertsPage) are transparent and rely on this.
    if (width >= 720) {
      return Scaffold(
        backgroundColor: GlassColors.background,
        // A Stack (not a Column) so the nav bar floats over page content
        // instead of owning its own separate row of layout space — content
        // needs to actually scroll underneath it for its glass blur to show
        // anything through it rather than just a flat backdrop. Pages give
        // their own scrollable content a matching top clearance (see
        // kGlassNavBarClearance in feed_page.dart) so nothing starts out
        // hidden behind the bar.
        body: Stack(
          children: [
            Positioned.fill(child: _pages[selectedIndex]),
            // A full-width, softly-blurred fade behind the nav bar pill —
            // without this, only the pill's own rounded-rect gets blurred,
            // so scrolled content shows a hard, sharp-edged seam at the
            // pill's exact boundary instead of an atmospheric transition.
            const Positioned(top: 0, left: 0, right: 0, child: _TopScrim()),
            // Positioned (not a bare Stack child) so it hugs the top edge
            // with its own natural height — GlassTopNavBar centers its
            // content internally via a Center widget, which shrink-wraps
            // under the unbounded height a Column used to give it, but
            // expands to fill all available height (vertically centering
            // the bar on the whole page) if just dropped into a Stack with
            // bounded height and no Positioned constraint.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassTopNavBar(
                selectedIndex: selectedIndex,
                unreadAlerts: unreadAlerts,
                onDestinationSelected: (i) => ref
                    .read(appShellIndexProvider.notifier)
                    .onDestinationSelected(context, ref, i),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: GlassColors.background,
      body: _pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => ref
            .read(appShellIndexProvider.notifier)
            .onDestinationSelected(context, ref, i),
        backgroundColor: GlassColors.surface,
        indicatorColor: const Color(0xFF1E2035),
        // Explicit, same as the desktop nav bar's selected color — the
        // default Material 3 selected tint here is subtle enough to read
        // as barely-there next to GlassTopNavBar's clearly orange
        // selected tab, which looks like an inconsistency between the two
        // rather than a deliberate design choice.
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            color: states.contains(WidgetState.selected)
                ? GlassColors.orange400
                : GlassColors.textMuted,
          ),
        ),
        destinations: [
          for (final (i, (label, icon, selected)) in navDestinations(
            AppLocalizations.of(context)!,
          ).indexed)
            NavigationDestination(
              icon: i == 1 && unreadAlerts > 0
                  ? Badge(
                      label: Text(unreadAlerts.toString()),
                      child: Icon(icon, color: GlassColors.textMuted),
                    )
                  : Icon(icon, color: GlassColors.textMuted),
              selectedIcon: i == 1 && unreadAlerts > 0
                  ? Badge(
                      label: Text(unreadAlerts.toString()),
                      child: Icon(selected, color: GlassColors.orange400),
                    )
                  : Icon(selected, color: GlassColors.orange400),
              label: label,
            ),
        ],
      ),
    );
  }
}

/// Full-width backdrop blur + top-to-transparent fade sitting behind
/// [GlassTopNavBar]'s own pill — see the call site's comment for why this
/// exists. Height matches [kGlassNavBarClearance] (feed_page.dart) exactly,
/// since that's the same measurement pages use to keep content clear of the
/// bar; this way the fade's bottom edge lines up with where content clears.
class _TopScrim extends StatelessWidget {
  const _TopScrim();

  // A single BackdropFilter blurs uniformly across its whole clipped region
  // and then stops dead at that region's exact edge — the blur itself has a
  // hard boundary, not just whatever color/opacity is layered on top of it,
  // so one blur layer always shows a visible sharp/blurred seam no matter
  // how soft its color gradient is. Stacking a few layers of decreasing
  // height *and* decreasing blur strength approximates a gradual falloff
  // instead — each layer's edge is hidden under the still-blurred layer
  // above it. Cheap here since it's one static region, not per-card.
  static const _layers = [
    (heightFactor: 1.0, sigma: 14.0, tint: 0.55),
    (heightFactor: 0.7, sigma: 8.0, tint: 0.4),
    (heightFactor: 0.4, sigma: 4.0, tint: 0.25),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: kGlassNavBarClearance,
        child: Stack(
          children: [
            for (final layer in _layers)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: kGlassNavBarClearance * layer.heightFactor,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: layer.sigma,
                      sigmaY: layer.sigma,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            GlassColors.background.withValues(
                              alpha: layer.tint,
                            ),
                            GlassColors.background.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
