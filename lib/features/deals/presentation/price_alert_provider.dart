import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

part 'price_alert_provider.g.dart';

@riverpod
class PriceAlertNotifier extends _$PriceAlertNotifier {
  @override
  Future<void> build() async {
    // No-op, just to have a notifier.
  }

  Future<bool> createAlert({
    required String productId,
    required String productTitle,
    required String productUrl,
    required double targetPrice,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      // Return false or throw a specific exception if the user is not logged in.
      return false;
    }

    final supabase = Supabase.instance.client;

    final alertData = {
      'product_id': productId,
      'user_id': user.uid,
      'user_email': user.email,
      'target_price': targetPrice,
      'product_title': productTitle,
      'product_url': productUrl,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await supabase.from('price_alerts').insert(alertData);
      return true;
    } catch (e) {
      // Log the error for debugging.
      print('Failed to save price alert: $e');
      return false;
    }
  }
}
