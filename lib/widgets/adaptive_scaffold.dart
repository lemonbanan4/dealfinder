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

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    FeedPage(),
    AlertsPage(),
    SettingsPage(),
  ];

  static const _destinations = <(String, IconData, IconData)>[
    ('Feed', Icons.storefront_outlined, Icons.storefront),
    ('Alerts', Icons.notifications_outlined, Icons.notifications),
    ('Settings', Icons.settings_outlined, Icons.settings),
  ];

  Future<void> _onDestinationSelected(int index) async {
    if (index == 1 && ref.read(authNotifierProvider) == null) {
      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(builder: (_) => const LoginPage()),
      );
      if (signedIn == true && mounted) {
        setState(() => _selectedIndex = 1);
      }
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (width >= 720) {
      final isExtended = width >= 1200;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: isExtended,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: isExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              backgroundColor: isDark ? const Color(0xFF0C0D15) : null,
              indicatorColor: isDark ? const Color(0xFF1E2035) : null,
              selectedIconTheme: isDark
                  ? const IconThemeData(color: Color(0xFF00B4FF))
                  : null,
              unselectedIconTheme: isDark
                  ? const IconThemeData(color: Color(0xFF5A5A78))
                  : null,
              selectedLabelTextStyle: isDark
                  ? const TextStyle(
                      color: Color(0xFF00B4FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    )
                  : null,
              unselectedLabelTextStyle: isDark
                  ? const TextStyle(color: Color(0xFF5A5A78), fontSize: 11)
                  : null,
              leading: _BrandHeader(extended: isExtended, isDark: isDark),
              trailing: _SidebarLegalLinks(extended: isExtended),
              destinations: [
                for (final (label, icon, selected) in _destinations)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selected),
                    label: Text(label),
                  ),
              ],
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
          for (final (label, icon, selected) in _destinations)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selected),
              label: label,
            ),
        ],
      ),
    );
  }
}

// ─── Brand header (NavigationRail leading) ────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.extended, required this.isDark});
  final bool extended;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: extended
          ? const Padding(
              padding: EdgeInsets.only(left: 4),
              child: AppLogo(iconSize: 20, fontSize: 15),
            )
          : const Icon(Icons.radar, color: Color(0xFF00B4FF), size: 24),
    );
  }
}

// ─── Sidebar legal links (NavigationRail trailing) ───────────────────────────
//
// Rendered only when the rail is extended (≥ 1200 px). NavigationRail
// automatically wraps `trailing` in an Expanded widget, which pushes this
// section to the very bottom of the sidebar.

class _SidebarLegalLinks extends StatelessWidget {
  const _SidebarLegalLinks({required this.extended});
  final bool extended;

  static const _kMuted = Color(0xFF5A5A78);
  static const _kDimmer = Color(0xFF3A3A52);
  static const _kBorder = Color(0xFF252638);

  @override
  Widget build(BuildContext context) {
    // Only show in full extended sidebar — nothing to display in the compact rail.
    if (!extended) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: _kBorder, height: 20, thickness: 1),
          _LegalLink(
            label: 'About Us',
            onTap: () => _push(context, const AboutUsPage()),
          ),
          const SizedBox(height: 7),
          _LegalLink(
            label: 'Privacy Policy',
            onTap: () => _push(context, const PrivacyPolicyPage()),
          ),
          const SizedBox(height: 7),
          _LegalLink(
            label: 'Terms of Service',
            onTap: () => _push(context, const TermsOfServicePage()),
          ),
          const SizedBox(height: 12),
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
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}

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
            color: _SidebarLegalLinks._kMuted,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
