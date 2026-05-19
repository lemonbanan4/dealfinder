import 'package:flutter/material.dart';

import '../features/alerts/presentation/alerts_page.dart';
import '../features/deals/presentation/feed_page.dart';
import '../features/settings/presentation/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
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
              onDestinationSelected: (i) =>
                  setState(() => _selectedIndex = i),
              labelType: isExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              backgroundColor:
                  isDark ? const Color(0xFF0C0D15) : null,
              indicatorColor:
                  isDark ? const Color(0xFF1E2035) : null,
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
                  ? const TextStyle(
                      color: Color(0xFF5A5A78),
                      fontSize: 11,
                    )
                  : null,
              leading: _BrandHeader(extended: isExtended, isDark: isDark),
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
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.extended, required this.isDark});
  final bool extended;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: extended
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 4),
                _logoMark(),
                const SizedBox(width: 10),
                Text(
                  'DealFinder',
                  style: TextStyle(
                    color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            )
          : _logoMark(),
    );
  }

  Widget _logoMark() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF006EFF), Color(0xFF00B4FF)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006EFF).withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 20),
    );
  }
}
