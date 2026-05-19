import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_provider.dart';
import '../domain/price_alert.dart';
import '../providers/alerts_provider.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsNotifierProvider);
    final settings = ref.watch(appSettingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Price Alerts')),
      body: alerts.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertTile(
                  alert: alert,
                  onDismiss: () =>
                      ref.read(alertsNotifierProvider.notifier).remove(alert.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add alert',
        onPressed: () {
          final notifier = ref.read(alertsNotifierProvider.notifier);
          final currency = settings.displayCurrency;
          showDialog<void>(
            context: context,
            builder: (ctx) => _AddAlertDialog(
              displayCurrency: currency,
              onAdd: ({required String title, required double price}) {
                notifier.add(
                  title: title,
                  targetPrice: price,
                  displayCurrency: currency,
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onDismiss});

  final PriceAlert alert;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(alert.id),
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: theme.colorScheme.error,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.delete, color: theme.colorScheme.onError),
          ),
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: ListTile(
        leading: Icon(
          alert.isTriggered
              ? Icons.notifications_active
              : Icons.notifications_outlined,
          color: alert.isTriggered ? theme.colorScheme.primary : null,
        ),
        title: Text(alert.title),
        subtitle: Text(
          '${alert.targetPrice.toStringAsFixed(2)} ${alert.displayCurrency}',
        ),
        trailing: alert.isTriggered
            ? Chip(
                label: const Text('Triggered'),
                backgroundColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              )
            : null,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_outlined, size: 64),
          SizedBox(height: 16),
          Text('No price alerts set.'),
          SizedBox(height: 8),
          Text('Tap + to create your first alert.'),
        ],
      ),
    );
  }
}

class _AddAlertDialog extends StatefulWidget {
  const _AddAlertDialog({
    required this.displayCurrency,
    required this.onAdd,
  });

  final String displayCurrency;
  final void Function({required String title, required double price}) onAdd;

  @override
  State<_AddAlertDialog> createState() => _AddAlertDialogState();
}

class _AddAlertDialogState extends State<_AddAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onAdd(
      title: _titleCtrl.text.trim(),
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
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Item / search query',
                hintText: 'e.g. iPhone 14 Pro',
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              decoration: InputDecoration(
                labelText: 'Target price (${widget.displayCurrency})',
                hintText: '0.00',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Enter a valid number';
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
          child: const Text('Add'),
        ),
      ],
    );
  }
}
