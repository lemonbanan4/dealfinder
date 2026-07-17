import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../deals/presentation/feed_page.dart' show feedFiltersProvider;
import '../../../deals/providers/recently_viewed_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/glass_dialog.dart';
import 'section_label.dart';
import 'setting_divider.dart';
import 'tappable_setting_row.dart';
import 'settings_card.dart';

class DangerZoneSection extends ConsumerWidget {
  const DangerZoneSection({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: Text(l10n.signOut),
      content: Text(l10n.signOutConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.signOut),
        ),
      ],
    );
    if (confirm != true) return;
    await _handlePostSignOutCleanup(ref);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: Text(l10n.deleteAccount),
      content: Text(l10n.deleteAccountConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n.delete),
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToDeleteAccount),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handlePostSignOutCleanup(WidgetRef ref) async {
    // Goes through Auth.signOut() (not FirebaseAuth directly) so local
    // favorites are cleared before signing out — otherwise they'd leak into
    // whichever account signs in next on this device.
    await ref.read(authProvider.notifier).signOut();
    ref.invalidate(feedFiltersProvider);
    ref.read(recentlyViewedProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        SectionLabel(l10n.dangerZoneSection),
        SettingsCard(
          child: Column(
            children: [
              TappableSettingRow(
                icon: Icons.logout,
                label: l10n.signOut,
                isDestructive: true,
                onTap: () => _signOut(context, ref),
              ),
              const SettingDivider(),
              TappableSettingRow(
                icon: Icons.delete_forever,
                label: l10n.deleteAccount,
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
