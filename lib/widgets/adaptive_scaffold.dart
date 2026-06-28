import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/alerts/presentation/alerts_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/deals/presentation/feed_page.dart';
import '../features/legal/presentation/about_us_page.dart';
import '../features/legal/presentation/privacy_policy_page.dart';
import '../features/legal/presentation/terms_of_service_page.dart';
import '../features/settings/presentation/settings_page.dart';
import 'app_logo.dart';
import '../features/alerts/providers/unread_alerts_provider.dart';

// Top-level nav destinations — shared by the custom sidebar and the mobile bar.
const _navDestinations = <(String, IconData, IconData)>[
  ('Feed', Icons.storefront_outlined, Icons.storefront),
  ('Alerts', Icons.notifications_outlined, Icons.notifications),
  ('Settings', Icons.settings_outlined, Icons.settings),
];

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[FeedPage(), AlertsPage()];

  Future<void> _onDestinationSelected(int index) async {
    if (index == 1 && ref.read(authProvider) == null) {
      final signedIn = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute<bool>(builder: (_) => const LoginPage()));
      if (signedIn == true && mounted) {
        setState(() => _selectedIndex = 1);
        ref.read(unreadAlertsProvider.notifier).updateCount(0);
      }
      return;
    }
    setState(() => _selectedIndex = index);
    if (index == 1) {
      ref.read(unreadAlertsProvider.notifier).updateCount(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadAlerts = ref.watch(unreadAlertsProvider);

    if (width >= 720) {
      final isExtended = width >= 1200;
      return Scaffold(
        body: Row(
          children: [
            _CustomSidebar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              extended: isExtended,
              isDark: isDark,
              unreadAlerts: unreadAlerts,
            ),
            Container(
              width: 1,
              color: isDark
                  ? const Color(0xFF252638)
                  : Theme.of(context).dividerColor,
            ),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: isDark ? const Color(0xFF0C0D15) : null,
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

// ─── Custom sidebar ───────────────────────────────────────────────────────────
//
// Replaces NavigationRail so we have full layout control. Legal links sit
// directly below the Settings item in the same Column — no Spacer, no
// Expanded, no trailing tricks. They are always visible regardless of height.

class _CustomSidebar extends StatelessWidget {
  const _CustomSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.extended,
    required this.isDark,
    required this.unreadAlerts,
  });

  final int selectedIndex;
  final void Function(int) onDestinationSelected;
  final bool extended;
  final bool isDark;
  final int unreadAlerts;

  static const _kBg = Color(0xFF0C0D15);
  static const _kBorder = Color(0xFF252638);
  static const _kDimmer = Color(0xFF3A3A52);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: extended ? 256 : 80,
      color: isDark ? _kBg : Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand header ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: extended
                ? const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: AppLogo(iconSize: 30, fontSize: 25),
                  )
                : const Center(
                    child: Icon(
                      Icons.radar,
                      color: Color(0xFF00B4FF),
                      size: 24,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          // ── Nav items ────────────────────────────────────────────────────────
          for (int i = 0; i < _navDestinations.length; i++)
            _SidebarNavItem(
              label: _navDestinations[i].$1,
              icon: _navDestinations[i].$2,
              selectedIcon: _navDestinations[i].$3,
              selected: selectedIndex == i,
              onTap: () => onDestinationSelected(i),
              extended: extended,
              isDark: isDark,
              badgeCount: _navDestinations[i].$1 == 'Alerts' ? unreadAlerts : 0,
            ),
          // ── Legal links — right below Settings, no spacer ────────────────────
          if (extended) ...[
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Divider(color: _kBorder, height: 1, thickness: 1),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegalLink(
                    label: 'About Us',
                    onTap: () => _push(context, const AboutUsPage()),
                  ),
                  const SizedBox(height: 6),
                  _LegalLink(
                    label: 'Privacy Policy',
                    onTap: () => _push(context, const PrivacyPolicyPage()),
                  ),
                  const SizedBox(height: 6),
                  _LegalLink(
                    label: 'Terms of Service',
                    onTap: () => _push(context, const TermsOfServicePage()),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '© ${DateTime.now().year} PrisPuls',
                    style: const TextStyle(
                      color: _kDimmer,
                      fontSize: 10,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }
}

// ─── Sidebar nav item ─────────────────────────────────────────────────────────

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    required this.extended,
    required this.isDark,
    required this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final bool extended;
  final bool isDark;
  final int badgeCount;

  static const _kSelected = Color(0xFF00B4FF);
  static const _kUnselected = Color(0xFF5A5A78);
  static const _kIndicator = Color(0xFF1E2035);

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? (selected ? _kSelected : _kUnselected) : null;
    final textColor = iconColor;

    Widget iconWidget = Icon(
      selected ? selectedIcon : icon,
      color: iconColor,
      size: 22,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(label: Text(badgeCount.toString()), child: iconWidget);
    }

    if (extended) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: selected && isDark
                  ? BoxDecoration(
                      color: _kIndicator,
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Row(
                children: [
                  iconWidget,
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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

    // Compact: icon pill + label stacked
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  decoration: selected && isDark
                      ? BoxDecoration(
                          color: _kIndicator,
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  child: iconWidget,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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

// ─── Legal link text button ───────────────────────────────────────────────────

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5A5A78),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
