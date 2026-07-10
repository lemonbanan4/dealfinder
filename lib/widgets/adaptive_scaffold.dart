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
        body: Column(
          children: [
            GlassTopNavBar(
              selectedIndex: selectedIndex,
              unreadAlerts: unreadAlerts,
              onDestinationSelected: (i) => ref
                  .read(appShellIndexProvider.notifier)
                  .onDestinationSelected(context, ref, i),
            ),
            Expanded(child: _pages[selectedIndex]),
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
        destinations: [
          for (final (i, (label, icon, selected))
              in navDestinations(AppLocalizations.of(context)!).indexed)
            NavigationDestination(
              icon: i == 1 && unreadAlerts > 0
                  ? Badge(
                      label: Text(unreadAlerts.toString()),
                      child: Icon(icon),
                    )
                  : Icon(icon),
              selectedIcon: i == 1 && unreadAlerts > 0
                  ? Badge(
                      label: Text(unreadAlerts.toString()),
                      child: Icon(selected),
                    )
                  : Icon(selected),
              label: label,
            ),
        ],
      ),
    );
  }
}
