import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../widgets/app_logo.dart';
import '../../deals/providers/scraper_configs_provider.dart';
import '../providers/settings_provider.dart';

const _kCardBg = Color(0xFF12131A);
const _kBorder = Color(0xFF252638);
const _kAccent = Color(0xFF00B4FF);
const _kMuted = Color(0xFF5A5A78);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // ── Currency & Region ─────────────────────────────────────────────
          _SectionLabel('Currency & Region'),
          _SettingsCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  expandedInsets: EdgeInsets.zero,
                  segments: const [
                    ButtonSegment(value: CurrencyCode.eur, label: Text('EUR')),
                    ButtonSegment(value: CurrencyCode.nok, label: Text('NOK')),
                    ButtonSegment(value: CurrencyCode.sek, label: Text('SEK')),
                    ButtonSegment(value: CurrencyCode.usd, label: Text('USD')),
                  ],
                  selected: {settings.displayCurrency},
                  onSelectionChanged: (s) =>
                      notifier.setDisplayCurrency(s.first),
                ),
                const SizedBox(height: 10),
                _VatNote(currency: settings.displayCurrency, isDark: isDark),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Auto-refresh ─────────────────────────────────────────────────
          _SectionLabel('Auto-Refresh'),
          _SettingsCard(
            isDark: isDark,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: const [
                ButtonSegment(value: 15, label: Text('15 min')),
                ButtonSegment(value: 30, label: Text('30 min')),
                ButtonSegment(value: 60, label: Text('1 hr')),
              ],
              selected: {settings.refreshIntervalMinutes},
              onSelectionChanged: (s) => notifier.setRefreshInterval(s.first),
            ),
          ),

          const SizedBox(height: 12),

          // ── Notifications ─────────────────────────────────────────────────
          _SectionLabel('Notifications'),
          _SettingsCard(
            isDark: isDark,
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text('Price-alert notifications'),
              subtitle: Text(
                'Notified when a deal drops below your target',
                style: TextStyle(
                  color: isDark ? _kMuted : null,
                  fontSize: 12,
                ),
              ),
              value: settings.notificationsEnabled,
              onChanged: (v) => notifier.toggleNotifications(enabled: v),
              activeThumbColor: _kAccent,
            ),
          ),

          const SizedBox(height: 12),

          // ── Deal sources ──────────────────────────────────────────────────
          _SectionLabel('Deal Sources'),
          _SourcesList(isDark: isDark),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── VAT/region note ───────────────────────────────────────────────────────────

class _VatNote extends StatelessWidget {
  const _VatNote({required this.currency, required this.isDark});
  final String currency;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final String note = switch (currency) {
      'NOK' => 'Prices include 25% MVA · Norway',
      'SEK' => 'Prices include 25% moms · Sweden',
      _ => 'Prices shown exclude VAT',
    };
    final color = isDark
        ? _kMuted
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(Icons.info_outline, size: 13, color: color),
        const SizedBox(width: 6),
        Text(note, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

// ── Sources list ──────────────────────────────────────────────────────────────

class _SourcesList extends ConsumerWidget {
  const _SourcesList({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(scraperConfigsProvider);
    final notifier = ref.read(scraperConfigsProvider.notifier);

    if (configs.isEmpty) {
      return _SettingsCard(
        isDark: isDark,
        child: Text(
          'No sources configured.',
          style: TextStyle(color: isDark ? _kMuted : null),
        ),
      );
    }

    return _SettingsCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < configs.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: isDark ? _kBorder : null),
            SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              title: Text(configs[i].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    configs[i].baseUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? _kMuted : null,
                      fontSize: 12,
                    ),
                  ),
                  if (configs[i].lastError != null) ...[
                    const SizedBox(height: 6),
                    _ScraperErrorBanner(
                      error: configs[i].lastError!,
                      at: configs[i].lastErrorAt,
                    ),
                  ],
                ],
              ),
              secondary: Chip(
                label: Text(configs[i].currencyCode),
                visualDensity: VisualDensity.compact,
              ),
              value: configs[i].isEnabled,
              onChanged: (v) => notifier.toggle(configs[i].id, enabled: v),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Scraper error banner ──────────────────────────────────────────────────────

const _kError = Color(0xFFFF4757);
const _kErrorText = Color(0xFFFF8B95);

class _ScraperErrorBanner extends StatelessWidget {
  const _ScraperErrorBanner({required this.error, required this.at});
  final String error;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    final when = at != null ? _formatErrorAt(at!) : 'unknown time';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 71, 87, 0.08),
        border: Border.all(color: const Color.fromRGBO(255, 71, 87, 0.30)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, size: 13, color: _kError),
              const SizedBox(width: 5),
              Text(
                'Scrape failed · $when',
                style: const TextStyle(
                  color: _kError,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            error,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _kErrorText,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatErrorAt(DateTime at) {
  final diff = DateTime.now().difference(at);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${at.day} ${months[at.month - 1]}';
}

// ── Shared primitives ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isDark,
    required this.child,
    this.padding,
  });
  final bool isDark;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark
            ? _kCardBg
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? _kBorder
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
