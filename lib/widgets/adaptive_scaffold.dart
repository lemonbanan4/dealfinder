import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

import '../features/alerts/presentation/alerts_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/deals/presentation/feed_page.dart';
import '../features/settings/presentation/settings_page.dart';
import 'app_logo.dart';
import '../features/settings/providers/cookie_consent_provider.dart';
import 'cookie_consent_banner.dart';
import '../features/alerts/providers/unread_alerts_provider.dart';
import '../theme/glass_colors.dart';

part 'adaptive_scaffold.g.dart';

// Top-level nav destinations — shared by the top glass nav bar and the mobile bar.
const _navDestinations = <(String, IconData, IconData)>[
  ('Feed', Icons.storefront_outlined, Icons.storefront),
  ('Alerts', Icons.notifications_outlined, Icons.notifications),
  ('Settings', Icons.settings_outlined, Icons.settings),
];

const _pages = <Widget>[FeedPage(), AlertsPage(), SettingsPage()];

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
        ref.read(unreadAlertsProvider.notifier).updateCount(0);
      }
      return;
    }
    state = index;
    if (index == 1) {
      ref.read(unreadAlertsProvider.notifier).updateCount(0);
    }
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Expanded(child: _AppShellMain()),
        const CookieConsentBanner(),
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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final unreadAlerts = ref.watch(unreadAlertsProvider);
    final selectedIndex = ref.watch(appShellIndexProvider);

    if (width >= 720) {
      return Scaffold(
        backgroundColor: GlassColors.background,
        body: Column(
          children: [
            _GlassTopNavBar(
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => ref
            .read(appShellIndexProvider.notifier)
            .onDestinationSelected(context, ref, i),
        backgroundColor: isDark ? GlassColors.background : null,
        indicatorColor: isDark ? const Color(0xFF1E2035) : null,
        destinations: [
          for (final (label, icon, selected) in _navDestinations)
            NavigationDestination(
              icon: label == 'Alerts' && unreadAlerts > 0
                  ? Badge(
                      label: Text(unreadAlerts.toString()),
                      child: Icon(icon),
                    )
                  : Icon(icon),
              selectedIcon: label == 'Alerts' && unreadAlerts > 0
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

// ─── Top glass nav bar (desktop/tablet) ────────────────────────────────────────
//
// Replaces the old sidebar with a sticky, centered horizontal "Liquid Glass"
// bar per the design system: a persistent Feed/Alerts/Settings switcher plus
// the logo and auth icon, living above every page rather than beside it.

class _GlassTopNavBar extends ConsumerWidget {
  const _GlassTopNavBar({
    required this.selectedIndex,
    required this.unreadAlerts,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final int unreadAlerts;
  final void Function(int) onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(11, 14, 20, 0.82),
            border: Border(bottom: BorderSide(color: GlassColors.glowBorder)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const AppLogo(iconSize: 26, fontSize: 20),
                    const SizedBox(width: 36),
                    for (int i = 0; i < _navDestinations.length; i++)
                      _TopNavItem(
                        label: _navDestinations[i].$1,
                        icon: _navDestinations[i].$2,
                        selectedIcon: _navDestinations[i].$3,
                        selected: selectedIndex == i,
                        badgeCount: _navDestinations[i].$1 == 'Alerts' ? unreadAlerts : 0,
                        onTap: () => onDestinationSelected(i),
                      ),
                    const Spacer(),
                    const _TopNavAuthIcon(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNavItem extends StatelessWidget {
  const _TopNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    required this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  static const _selectedColor = Color(0xFF00B4FF);
  static const _unselectedColor = Color(0xFF8A8AA0);

  @override
  Widget build(BuildContext context) {
    final color = selected ? _selectedColor : _unselectedColor;
    Widget iconWidget = Icon(selected ? selectedIcon : icon, color: color, size: 20);
    if (badgeCount > 0) {
      iconWidget = Badge(label: Text(badgeCount.toString()), child: iconWidget);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1E2035) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: selected
                  ? Border.all(color: GlassColors.glowBorderHover)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNavAuthIcon extends ConsumerWidget {
  const _TopNavAuthIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return authState.when(
      data: (user) => IconButton(
        tooltip: user != null ? 'Profile' : 'Sign In',
        icon: Icon(
          user != null ? Icons.account_circle : Icons.person_outline,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  user != null ? const SettingsPage() : const LoginPage(),
            ),
          );
        },
      ),
      loading: () => const SizedBox(width: 48),
      error: (e, s) => const Icon(Icons.error, color: Colors.white),
    );
  }
}
