import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(title: const AppLogo()),
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
