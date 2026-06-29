import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../deals/providers/recently_viewed_provider.dart';
import '../../../legal/presentation/about_us_page.dart';
import '../../../legal/presentation/privacy_policy_page.dart';
import '../../../legal/presentation/terms_of_service_page.dart';
import '../../../../widgets/glass_dialog.dart';
import 'section_label.dart';
import 'setting_divider.dart';
import 'tappable_setting_row.dart';
import 'settings_card.dart';

class DataPrivacySection extends ConsumerWidget {
  const DataPrivacySection({super.key});

  Future<void> _clearRecents(BuildContext context, WidgetRef ref) async {
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: const Text('Clear History'),
      content: const Text('Clear all recently viewed items?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Clear'),
        ),
      ],
    );
    if (confirm == true) {
      ref.read(recentlyViewedProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Data & Privacy'),
        SettingsCard(
          child: Column(
            children: [
              TappableSettingRow(
                icon: Icons.history_toggle_off,
                label: 'Clear recently viewed',
                onTap: () => _clearRecents(context, ref),
              ),
              const SettingDivider(),
              TappableSettingRow(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                ),
              ),
              const SettingDivider(),
              TappableSettingRow(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
                ),
              ),
              const SettingDivider(),
              TappableSettingRow(
                icon: Icons.info_outline,
                label: 'About Us',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsPage()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
