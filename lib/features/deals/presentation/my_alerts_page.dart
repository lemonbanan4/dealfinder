import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../settings/presentation/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../widgets/glass_dialog.dart';
import '../providers/recently_viewed_provider.dart';
import 'price_alert.dart';
import 'my_alerts_provider.dart';

class MyAlertsPage extends ConsumerWidget {
  const MyAlertsPage({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PriceAlert alert,
  ) async {
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: const Text('Delete Alert'),
      content: const Text('Are you sure you want to delete this price alert?'),
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

    if (confirm == true && context.mounted) {
      try {
        await ref.read(myAlertsProvider.notifier).deleteAlert(alert.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert deleted.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete alert: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(myAlertsProvider);
    final settings = ref.watch(appSettingsProvider);
    final currencyConverter = ref.watch(currencyConverterProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('My Price Alerts')),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('No price alerts set yet.'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final targetPrice = currencyConverter.convert(
                alert.targetPrice,
                'EUR', // Assuming target price is stored in EUR
                settings.displayCurrency,
              );
              final latestPrice = alert.latestPrice != null
                  ? currencyConverter.convert(
                      alert.latestPrice!,
                      alert.currency ?? 'EUR',
                      settings.displayCurrency,
                    )
                  : null;

              final priceFormat = NumberFormat.currency(
                symbol: settings.displayCurrency,
                decimalDigits: 0,
              );

              return Card(
                child: ListTile(
                  title: Text(
                    alert.productTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Alert when below: ${priceFormat.format(targetPrice)}',
                      ),
                      if (latestPrice != null)
                        Text(
                          'Latest price: ${priceFormat.format(latestPrice)}',
                          style: TextStyle(
                            color: latestPrice <= targetPrice
                                ? Colors.green
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, ref, alert),
                    tooltip: 'Delete Alert',
                  ),
                  onTap: () {
                    ref
                        .read(recentlyViewedProvider.notifier)
                        .addDeal(alert.productId);
                    launchUrl(
                      Uri.parse(alert.productUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
