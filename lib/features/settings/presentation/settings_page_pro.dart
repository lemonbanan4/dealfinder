import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../legal/presentation/about_us_page.dart';
import '../../legal/presentation/privacy_policy_page.dart';
import '../../legal/presentation/terms_of_service_page.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_list_tile.dart';

/// A modern, well-structured settings page.
class SettingsPagePro extends ConsumerWidget {
  const SettingsPagePro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final currentTheme = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // --- Account Section ---
          SettingsGroup(
            title: 'Account',
            children: [
              if (user != null)
                SettingsListTile(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: user.email,
                  onTap: () {
                    // TODO: Navigate to Profile Page
                  },
                )
              else
                SettingsListTile(
                  icon: Icons.login,
                  title: 'Sign In / Register',
                  onTap: () =>
                      ref.read(authProvider.notifier).signInWithGoogle(),
                ),
              if (user != null)
                SettingsListTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () async {
                    final confirmed = await _showConfirmationDialog(
                      context,
                      title: 'Sign Out?',
                      content: 'Are you sure you want to sign out?',
                    );
                    if (confirmed) {
                      ref.read(authProvider.notifier).signOut();
                    }
                  },
                ),
            ],
          ),

          // --- Preferences Section ---
          SettingsGroup(
            title: 'Preferences',
            children: [
              SettingsListTile(
                icon: Icons.language_outlined,
                title: 'Language',
                trailing: const Text('English'),
                onTap: () {
                  // TODO: Implement language selection
                },
              ),
              SettingsListTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: CupertinoSwitch(
                  // The switch is on if the theme is dark.
                  value: currentTheme == ThemeMode.dark,
                  onChanged: (value) {
                    // Call the notifier to toggle the theme.
                    ref.read(themeModeProvider.notifier).toggle(value);
                  },
                ),
                onTap: null, // The switch handles the interaction
              ),
              SettingsListTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // TODO: Navigate to notification settings
                },
              ),
            ],
          ),

          // --- About Section ---
          SettingsGroup(
            title: 'About',
            children: [
              SettingsListTile(
                icon: Icons.info_outline,
                title: 'About DealFinder Pro',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutUsPage()),
                  );
                },
              ),
              SettingsListTile(
                icon: Icons.gavel_outlined,
                title: 'Terms of Service',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TermsOfServicePage(),
                    ),
                  );
                },
              ),
              SettingsListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          // --- Danger Zone ---
          if (user != null)
            SettingsGroup(
              title: 'Danger Zone',
              children: [
                SettingsListTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  titleColor: theme.colorScheme.error,
                  iconColor: theme.colorScheme.error,
                  onTap: () async {
                    final confirmed = await _showConfirmationDialog(
                      context,
                      title: 'Delete Account?',
                      content:
                          'This action is irreversible. All your data, including alerts and favorites, will be permanently deleted.',
                      confirmText: 'Delete',
                    );
                    if (confirmed) {
                      // TODO: Implement account deletion logic
                      ref.read(authProvider.notifier).deleteAccount();
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
