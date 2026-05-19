// Exports the correct NotificationService implementation per platform.
// dart.library.io is present on native (iOS/Android/desktop), absent on web.
export 'web_notification_service.dart'
    if (dart.library.io) 'native_notification_service.dart';
