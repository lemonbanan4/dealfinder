import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../deals/providers/scraper_configs_provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsNotifierProvider);
    final notifier = ref.read(appSettingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Currency ──────────────────────────────────────────────────────
          const _SectionHeader('Display currency'),
          RadioGroup<String>(
            groupValue: settings.displayCurrency,
            onChanged: (v) => notifier.setDisplayCurrency(v!),
            child: Column(
              children: [
                for (final code in CurrencyCode.supported)
                  RadioListTile<String>(
                    title: Text(code),
                    value: code,
                  ),
              ],
            ),
          ),

          // ── Refresh interval ─────────────────────────────────────────────
          const Divider(indent: 16, endIndent: 16),
          const _SectionHeader('Auto-refresh interval'),
          RadioGroup<int>(
            groupValue: settings.refreshIntervalMinutes,
            onChanged: (v) => notifier.setRefreshInterval(v!),
            child: Column(
              children: [
                for (final min in [15, 30, 60])
                  RadioListTile<int>(
                    title: Text('Every $min minutes'),
                    value: min,
                  ),
              ],
            ),
          ),

          // ── Notifications ─────────────────────────────────────────────────
          const Divider(indent: 16, endIndent: 16),
          const _SectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Price-alert notifications'),
            subtitle: const Text(
              'Notified when a deal drops below your target',
            ),
            value: settings.notificationsEnabled,
            onChanged: (v) => notifier.toggleNotifications(enabled: v),
          ),

          // ── Sources ───────────────────────────────────────────────────────
          const Divider(indent: 16, endIndent: 16),
          const _SectionHeader('Deal sources'),
          const _SourcesList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Sources list ──────────────────────────────────────────────────────────────

class _SourcesList extends ConsumerWidget {
  const _SourcesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(scraperConfigsNotifierProvider);
    final configsNotifier = ref.read(scraperConfigsNotifierProvider.notifier);

    if (configs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('No sources configured.'),
      );
    }

    return Column(
      children: [
        for (final config in configs)
          SwitchListTile(
            title: Text(config.name),
            subtitle: Text(
              config.baseUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            secondary: Chip(
              label: Text(config.currencyCode),
              visualDensity: VisualDensity.compact,
            ),
            value: config.isEnabled,
            onChanged: (v) => configsNotifier.toggle(config.id, enabled: v),
          ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
