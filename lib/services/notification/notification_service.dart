abstract class NotificationService {
  Future<void> initialize();

  Future<void> showPriceAlert({
    required String title,
    required String body,
    required int id,
  });
}
