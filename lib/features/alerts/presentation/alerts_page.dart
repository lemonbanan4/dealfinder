import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_provider.dart';
import '../domain/price_alert.dart';
import '../providers/alerts_provider.dart';

const _kCardBg = Color(0xFF12131A);
const _kBorder = Color(0xFF252638);
const _kAccent = Color(0xFF00B4FF);
const _kGreen = Color(0xFF00E676);
const _kRed = Color(0xFFFF4757);
const _kMuted = Color(0xFF5A5A78);

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsNotifierProvider);
    final settings = ref.watch(appSettingsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Price Alerts',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(e.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(alertsNotifierProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (alerts) => alerts.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: alerts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return _AlertCard(
                    key: ValueKey(alert.id),
                    alert: alert,
                    isDark: isDark,
                    onDismiss: () => ref
                        .read(alertsNotifierProvider.notifier)
                        .remove(alert.id),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add price alert',
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('New Alert'),
        onPressed: () {
          final notifier = ref.read(alertsNotifierProvider.notifier);
          final currency = settings.displayCurrency;
          showDialog<void>(
            context: context,
            builder: (ctx) => _AddAlertDialog(
              displayCurrency: currency,
              onAdd: ({
                required String title,
                required String searchQuery,
                required double price,
              }) {
                notifier.add(
                  title: title,
                  targetPrice: price,
                  displayCurrency: currency,
                  searchQuery: searchQuery,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Alert card ────────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    super.key,
    required this.alert,
    required this.isDark,
    required this.onDismiss,
  });

  final PriceAlert alert;
  final bool isDark;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final accentColor = alert.isTriggered ? _kGreen : _kAccent;

    return Dismissible(
      key: ValueKey('dismiss_${alert.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: _kRed,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDismiss(),
      child: DecoratedBox(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: accentColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accentColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            alert.isTriggered
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_none_outlined,
                            color: accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                alert.title,
                                style: TextStyle(
                                  color: isDark ? Colors.white : null,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'Target ≤ ',
                                    style: TextStyle(
                                      color: isDark ? _kMuted : null,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${_fmt(alert.targetPrice)} ${alert.displayCurrency}',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (alert.isTriggered)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _kGreen.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _kGreen.withAlpha(80),
                              ),
                            ),
                            child: const Text(
                              'Triggered',
                              style: TextStyle(
                                color: _kGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fmt(double price) {
    final s = price.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_outlined, size: 64),
          const SizedBox(height: 16),
          Text(
            'No price alerts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          const Text('Tap New Alert to start tracking a deal.'),
        ],
      ),
    );
  }
}

// ── Add alert dialog ──────────────────────────────────────────────────────────

class _AddAlertDialog extends StatefulWidget {
  const _AddAlertDialog({
    required this.displayCurrency,
    required this.onAdd,
  });

  final String displayCurrency;
  final void Function({
    required String title,
    required String searchQuery,
    required double price,
  }) onAdd;

  @override
  State<_AddAlertDialog> createState() => _AddAlertDialogState();
}

class _AddAlertDialogState extends State<_AddAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keywordCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _keywordCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final keyword = _keywordCtrl.text.trim();
    widget.onAdd(
      title: keyword,
      searchQuery: keyword,
      price: double.parse(_priceCtrl.text),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Price Alert'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _keywordCtrl,
              decoration: const InputDecoration(
                labelText: 'Keyword',
                hintText: 'e.g. Tempur, RTX 4080, iPhone',
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              decoration: InputDecoration(
                labelText: 'Target price',
                hintText: '0',
                suffixText: widget.displayCurrency,
                helperText:
                    'Alert fires when a match drops to or below this price',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = double.tryParse(v);
                if (n == null) return 'Enter a valid number';
                if (n <= 0) return 'Must be greater than 0';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add Alert'),
        ),
      ],
    );
  }
}
