import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

final priceAlertsProvider = AsyncNotifierProvider<PriceAlertsNotifier, void>(
  () {
    return PriceAlertsNotifier();
  },
);

class PriceAlertsNotifier extends AsyncNotifier<void> {
  final _supabase = Supabase.instance.client;
  final _firebaseAuth = fb.FirebaseAuth.instance;

  @override
  Future<void> build() async {
    // Initial state is idle
  }

  /// Creates a new price alert in Supabase
  Future<bool> createAlert({
    required String productId,
    required String productTitle,
    required String productUrl,
    required double targetPrice,
    required String currency,
  }) async {
    state = const AsyncLoading();

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      state = AsyncError(
        'User must be logged in to set alerts',
        StackTrace.current,
      );
      return false;
    }

    try {
      await _supabase.from('price_alerts').insert({
        'user_id': currentUser.uid,
        'user_email': currentUser.email,
        'product_id': productId,
        'product_title': productTitle,
        'product_url': productUrl,
        'target_price': targetPrice,
        'currency': currency,
        'is_active': true,
      });

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncError('Failed to create alert: $e', st);
      return false;
    }
  }
}
