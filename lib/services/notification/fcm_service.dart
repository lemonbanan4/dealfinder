import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/alerts/presentation/alerts_page.dart';
import 'native_notification_service.dart';

/// Top-level function to handle FCM messages in the background.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  // Note: You can trigger local notifications or Hive updates here if needed.
}

class FCMService {
  static final _messaging = FirebaseMessaging.instance;

  // A global key to navigate from outside the widget tree
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    // 1. Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Local Notifications for foreground display
    await PlatformNotificationService().initialize(
      onPayload: (payload) => _handleNotificationTap(payload),
    );

    // 2. Request permissions (crucial for iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 3. Get the initial token and save it to Firestore
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      // 4. Listen to token refreshes and update Firestore
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

      // 5. Handle foreground messages natively
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          PlatformNotificationService().showNotification(
            id: message.messageId?.hashCode ?? DateTime.now().millisecond,
            title: notification.title ?? '',
            body: notification.body ?? '',
            payload: message.data['product_url'] ?? 'alerts_page',
          );
        }
      });

      // 6. Handle taps on background messages
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _handleNotificationTap(message.data['product_url']),
      );

      // 7. Handle tap if the app was completely terminated
      final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMsg != null) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => _handleNotificationTap(initialMsg.data['product_url']),
        );
      }
    }
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  static Future<void> _handleNotificationTap(String? payload) async {
    final navigator = navigatorKey.currentState;

    // If payload is a URL, open it in the browser
    if (payload != null && payload.startsWith('http')) {
      final uri = Uri.tryParse(payload);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Fallback: Open the alerts page
    if (navigator != null && navigator.mounted) {
      navigator.push(MaterialPageRoute(builder: (_) => const AlertsPage()));
    }
  }
}
