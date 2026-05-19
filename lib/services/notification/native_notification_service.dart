import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

const _channelId = 'dealfinder_price_alerts';
const _channelName = 'Price Alerts';

class PlatformNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
        macOS: DarwinInitializationSettings(),
      ),
    );

    // Create the Android notification channel (required for Android 8+).
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Fired when a deal drops to your target price',
            importance: Importance.high,
          ),
        );
  }

  @override
  Future<void> showPriceAlert({
    required String title,
    required String body,
    required int id,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }
}
