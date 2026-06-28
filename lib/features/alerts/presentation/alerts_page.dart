import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/app_logo.dart';
import '../providers/alerts_provider.dart';
import '../providers/alert_configs_provider.dart';
import '../domain/alert_config.dart';
import 'edit_alert_sheet.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/alert_repository.dart';

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
                      ? const Color(0xFF00B4FF)
                      : const Color(0xFF5A5A78),
                ),
                onPressed: hasUnread
                    ? () => ref.read(alertsProvider.notifier).markAllAsRead()
                    : null,
              ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF00B4FF),
            labelColor: Color(0xFF00B4FF),
            unselectedLabelColor: Color(0xFF5A5A78),
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
              color: const Color(0xFFFF4757),
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
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return configsAsync.when(
      data: (configs) {
        return Column(
          children: [
            // ── The Settings Toggle Moved Here ──
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF12131A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF252638)),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Email Notifications',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Get notified when targets are hit',
                    style: TextStyle(color: Color(0xFF5A5A78), fontSize: 12),
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (v) => notifier.toggleNotifications(enabled: v),
                  activeColor: const Color(0xFF00B4FF),
                ),
              ),
            ),

            // ── The List of Targets ──
            Expanded(
              child: configs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.track_changes_outlined,
                            size: 64,
                            color: Color(0xFF5A5A78),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No active targets',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: configs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ActiveTargetCard(config: configs[index]);
                      },
                    ),
            ),
          ],
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
    return Dismissible(
      key: ValueKey(config.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4757),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        ref.read(alertRepositoryProvider).deleteAlertConfig(config.id);
      },
      child: Material(
        color: const Color(0xFF12131A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF252638)),
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
                    color: Color(0xFF252638),
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
                        'Target: ${config.targetPrice.round()} SEK',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? const Color(0xFF252638)
              : const Color(0xFF00B4FF).withAlpha(100),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRead
                    ? const Color(0xFF252638)
                    : const Color(0xFF00B4FF).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: isRead
                    ? const Color(0xFF8A8AA0)
                    : const Color(0xFF00B4FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isRead ? const Color(0xFF8A8AA0) : Colors.white,
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: isRead
                          ? const Color(0xFF5A5A78)
                          : const Color(0xFF8A8AA0),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF5A5A78),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            color: Color(0xFF5A5A78),
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
            style: TextStyle(color: Color(0xFF8A8AA0)),
          ),
        ],
      ),
    );
  }
}
