import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/glass_colors.dart';
import '../../../widgets/app_logo.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/account_section.dart';
import 'widgets/preferences_section.dart';
import 'widgets/data_privacy_section.dart';
import 'widgets/danger_zone_section.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    // Always the dark glass look regardless of the user's light/dark theme
    // preference — matches the rest of the app (feed, nav bar), which is
    // deliberately dark-mode only per the design system.
    return Scaffold(
      backgroundColor: GlassColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const AppLogo(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const AccountSection(),
          const PreferencesSection(),
          const DataPrivacySection(),
          if (user != null) const DangerZoneSection(),
        ],
      ),
    );
  }
}
