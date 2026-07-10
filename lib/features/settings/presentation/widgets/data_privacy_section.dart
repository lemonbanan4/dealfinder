import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../deals/providers/recently_viewed_provider.dart';
import '../../../legal/presentation/about_us_page.dart';
import '../../../legal/presentation/privacy_policy_page.dart';
import '../../../legal/presentation/terms_of_service_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/glass_dialog.dart';
import 'section_label.dart';
import 'setting_divider.dart';
import 'tappable_setting_row.dart';
import 'settings_card.dart';

class DataPrivacySection extends ConsumerWidget {
  const DataPrivacySection({super.key});

  Future<void> _clearRecents(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: Text(l10n.clearHistoryTitle),
      content: Text(l10n.clearHistoryConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.clear),
        ),
      ],
    );
    if (confirm == true) {
      ref.read(recentlyViewedProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l10n.dataPrivacySection),
        SettingsCard(
          child: Column(
            children: [
              TappableSettingRow(
                icon: Icons.history_toggle_off,
                label: l10n.clearRecentlyViewed,
                onTap: () => _clearRecents(context, ref),
              ),
              const SettingDivider(),
              TappableSettingRow(
                icon: Icons.privacy_tip_outlined,
                label: l10n.footerPrivacyPolicy,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                ),
              ),
              const SettingDivider(),
              TappableSettingRow(
                icon: Icons.description_outlined,
                label: l10n.footerTermsOfService,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
                ),
              ),
              const SettingDivider(),
              TappableSettingRow(
                icon: Icons.info_outline,
                label: l10n.footerAboutUs,
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
