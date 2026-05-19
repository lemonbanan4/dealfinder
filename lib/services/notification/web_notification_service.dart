import 'dart:js_interop';

import 'notification_service.dart';

// Minimal JS interop binding for the Web Notifications API.
// Using a custom extension type avoids package:web version coupling.
@JS('Notification')
extension type _JsNotification._(JSObject _) implements JSObject {
  external static String get permission;
  external static JSPromise<JSString> requestPermission();
  external factory _JsNotification(String title, JSObject? options);
}

class PlatformNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    try {
      if (_JsNotification.permission == 'default') {
        await _JsNotification.requestPermission().toDart;
      }
    } catch (_) {
      // Browser does not support the Notifications API.
    }
  }

  @override
  Future<void> showPriceAlert({
    required String title,
    required String body,
    required int id,
  }) async {
    try {
      if (_JsNotification.permission != 'granted') return;
      final options = {'body': body, 'tag': id.toString()}.jsify()! as JSObject;
      _JsNotification(title, options);
    } catch (_) {
      // Silently swallow — notifications are best-effort.
    }
  }
}
