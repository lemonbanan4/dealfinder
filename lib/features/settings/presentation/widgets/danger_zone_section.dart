import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../deals/providers/recently_viewed_provider.dart';
import '../../../../widgets/glass_dialog.dart';
import 'section_label.dart';
import 'setting_divider.dart';
import 'tappable_setting_row.dart';
import 'settings_card.dart';

class DangerZoneSection extends ConsumerWidget {
  const DangerZoneSection({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sign Out'),
        ),
      ],
    );
    if (confirm != true) return;
    await _handlePostSignOutCleanup(ref);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: const Text('Delete Account'),
      content: const Text(
        'Are you sure you want to permanently delete your account? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    );

    if (confirm != true || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-north1',
      ).httpsCallable('delete_account');
      await callable.call();
      await _handlePostSignOutCleanup(ref);

      if (context.mounted) {
        Navigator.of(context)
          ..pop() // Dismiss loading dialog
          ..pop(); // Dismiss settings page
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete account. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePostSignOutCleanup(WidgetRef ref) async {
    await FirebaseAuth.instance.signOut();
    ref.invalidate(authProvider);
    ref.read(recentlyViewedProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SectionLabel('Danger Zone'),
        SettingsCard(
          child: Column(
            children: [
              TappableSettingRow(
                icon: Icons.logout,
                label: 'Sign Out',
                isDestructive: true,
                onTap: () => _signOut(context, ref),
              ),
              const SettingDivider(),
              TappableSettingRow(
                icon: Icons.delete_forever,
                label: 'Delete Account',
                isDestructive: true,
                onTap: () => _deleteAccount(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
