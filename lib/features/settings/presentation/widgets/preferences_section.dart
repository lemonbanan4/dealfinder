import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../deals/presentation/feed_page.dart' show regionProvider;
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import 'section_label.dart';
import 'segmented_switch.dart';
import 'setting_divider.dart';
import 'setting_row.dart';
import 'settings_card.dart';

const _supportedCurrencies = ['SEK', 'NOK', 'EUR', 'USD'];

class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final region = ref.watch(regionProvider);
    final regionNotifier = ref.read(regionProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Preferences'),
        SettingsCard(
          child: Column(
            children: [
              SettingRow(
                icon: Icons.public,
                label: 'Region',
                trailing: SegmentedSwitch<String>(
                  selected: region,
                  onSelect: (r) => regionNotifier.setRegion(r),
                  segments: const {'se': '🇸🇪 SE', 'no': '🇳🇴 NO'},
                ),
              ),
              const SettingDivider(),
              SettingRow(
                icon: Icons.color_lens_outlined,
                label: 'Theme',
                trailing: SegmentedSwitch<AppTheme>(
                  selected: theme,
                  onSelect: (t) => themeNotifier.updateTheme(t),
                  segments: const {
                    AppTheme.system: 'System',
                    AppTheme.light: 'Light',
                    AppTheme.dark: 'Dark',
                    AppTheme.amoled: 'Amoled',
                  },
                ),
              ),
              const SettingDivider(),
              SettingRow(
                icon: Icons.paid_outlined,
                label: 'Currency',
                trailing: SegmentedSwitch<String>(
                  selected: settings.displayCurrency,
                  onSelect: (c) => settingsNotifier.setDisplayCurrency(c),
                  segments: <String, String>{
                    for (var c in _supportedCurrencies) c: c,
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
