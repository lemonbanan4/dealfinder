import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants.dart';
import '../../../widgets/app_logo.dart';
import '../providers/alerts_provider.dart';
import '../providers/alert_configs_provider.dart';
import '../domain/alert_config.dart';
import '../../settings/presentation/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import 'edit_alert_sheet.dart';

/// Best-effort delete of the backend's `price_alerts` row for [productId] —
/// otherwise the scraper's price check has no idea an alert was dismissed
/// in-app and keeps emailing the user for it indefinitely.
Future<void> deleteBackendAlert(String productId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  try {
    final idToken = await user.getIdToken();
    final response = await http.delete(
      Uri.parse('${ApiUrls.apiUrl}/api/alerts/$productId'),
      headers: {'Authorization': 'Bearer $idToken'},
    );
    if (response.statusCode >= 400) {
      throw Exception(
        'Backend rejected the delete (${response.statusCode}): ${response.body}',
      );
    }
  } catch (e) {
    debugPrint('Failed to delete backend alert row: $e');
  }
}

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final hasUnread = alerts.any((a) => !a.isRead);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const AppLogo(),
          actions: [
            if (alerts.isNotEmpty)
              IconButton(
                tooltip: 'Mark all as read',
                icon: Icon(
                  Icons.mark_email_read_outlined,
                  color: hasUnread
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: hasUnread
                    ? () => ref.read(alertsProvider.notifier).markAllAsRead()
                    : null,
              ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            tabs: [
              Tab(text: 'Triggered'),
              Tab(text: 'Active Targets'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_TriggeredAlertsTab(), _ActiveTargetsTab()],
        ),
      ),
    );
  }
}

class _TriggeredAlertsTab extends ConsumerWidget {
  const _TriggeredAlertsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);

    if (alerts.isEmpty) return const _EmptyAlertsState();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Dismissible(
          key: ValueKey(alert.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          onDismissed: (direction) {
            ref.read(alertsProvider.notifier).deleteAlert(alert.id);
          },
          child: _AlertCard(
            title: alert.title,
            message: alert.message,
            time: _formatTime(alert.time),
            isRead: alert.isRead,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    }
    return 'Just now';
  }
}

class _ActiveTargetsTab extends ConsumerWidget {
  const _ActiveTargetsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configsAsync = ref.watch(alertConfigsProvider);

    return configsAsync.when(
      data: (configs) {
        return configs.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.track_changes_outlined,
                      size: 64,
                      color: Color(
                        0xFF5A5A78,
                      ), // Kept for specific design choice
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No active targets',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  // Invalidate the provider to force a refetch
                  ref.invalidate(alertConfigsProvider);
                  // Keep showing the indicator until the data is re-fetched
                  await ref.read(alertConfigsProvider.future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: configs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _ActiveTargetCard(config: configs[index]);
                  },
                ),
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('Error loading alerts')),
    );
  }
}

class _ActiveTargetCard extends ConsumerWidget {
  const _ActiveTargetCard({required this.config});
  final AlertConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final currencyConverter = ref.watch(currencyConverterProvider);
    final targetCurrency = settings.displayCurrency;

    final convertedPrice = currencyConverter.when(
      data: (rates) => rates != null
          ? ref
                .read(currencyConverterProvider.notifier)
                .convert(config.targetPrice, config.currency, targetCurrency)
          : config.targetPrice,
      loading: () => config.targetPrice,
      error: (_, _) => config.targetPrice,
    );
    return Dismissible(
      key: ValueKey(config.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        ref.read(alertRepositoryProvider).deleteAlertConfig(config.id);
        unawaited(deleteBackendAlert(config.productId));
      },
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => EditAlertSheet.show(context, config),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF252638), // Kept for specific design choice
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.track_changes,
                    color: Color(0xFF00B4FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.productTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target: ${convertedPrice.round()} $targetCurrency',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [
                            // Use tabular numbers for prices to prevent layout shifts
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  final String title;
  final String message;
  final String time;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isRead
        ? theme.colorScheme.outlineVariant
        : theme.colorScheme.primary.withAlpha(100);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AlertIcon(isRead: isRead),
            const SizedBox(width: 16),
            _AlertContent(
              title: title,
              message: message,
              time: time,
              isRead: isRead,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertIcon extends StatelessWidget {
  const _AlertIcon({required this.isRead});
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isRead
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primary.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications_active_outlined,
        color: isRead ? colorScheme.onSurfaceVariant : colorScheme.primary,
        size: 20,
      ),
    );
  }
}

class _AlertContent extends StatelessWidget {
  const _AlertContent({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  final String title;
  final String message;
  final String time;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isRead
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
              fontSize: 14,
              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlertsState extends StatelessWidget {
  const _EmptyAlertsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Color(0xFF5A5A78), // Kept for specific design choice
          ),
          const SizedBox(height: 16),
          Text(
            'No alerts yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'You will be notified here when prices drop.',
            style: TextStyle(
              color: Color(0xFF8A8AA0),
            ), // Kept for specific design choice
          ),
        ],
      ),
    );
  }
}
