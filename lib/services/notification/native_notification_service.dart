import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

// We bump the channel ID to v2 so Android recreates the channel with the new custom sound
const _channelId = 'dealfinder_price_alerts_v2';
const _channelName = 'Price Alerts';

class PlatformNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize({void Function(String?)? onPayload}) async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
        macOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (onPayload != null) onPayload(response.payload);
      },
    );

    // Create the Android notification channel (required for Android 8+).
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Fired when a deal drops to your target price',
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound('notification_sound'),
          ),
        );
  }

  @override
  Future<void> showPriceAlert({
    required String title,
    required String body,
    required int id,
    String? payload,
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
          icon: '@drawable/ic_notification',
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          sound: 'notification_sound.wav',
        ),
        macOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required int id,
    String? payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          sound: 'notification_sound.wav',
        ),
        macOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
