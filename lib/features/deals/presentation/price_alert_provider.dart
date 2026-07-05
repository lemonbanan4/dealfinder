import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../alerts/domain/alert_config.dart';
import '../../alerts/providers/alert_configs_provider.dart';
import '../../auth/providers/auth_provider.dart';

part 'price_alert_provider.g.dart';

@riverpod
class PriceAlertNotifier extends _$PriceAlertNotifier {
  @override
  Future<void> build() async {
    // No-op, just to have a notifier.
  }

  /// Creates a price alert. Throws on failure — callers must not assume
  /// success just because this returned without checking for an exception.
  Future<void> createAlert({
    required String productId,
    required String productTitle,
    required String productUrl,
    required double targetPrice,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      throw Exception('You must be signed in to set a price alert.');
    }
    if (!user.emailVerified) {
      throw Exception('Please verify your email to set price alerts.');
    }

    // Firestore's security rules re-check email verification against the ID
    // token's own `email_verified` claim, which can lag behind the client's
    // cached `emailVerified` flag until the token is refreshed — e.g. right
    // after the user verifies their email in the same session. Force a
    // refresh so a freshly-verified user isn't rejected by the rule.
    await fb.FirebaseAuth.instance.currentUser?.getIdToken(true);

    // Best-effort: also save to Supabase for the backend scraper's
    // server-side email-alert check. This is a secondary notification
    // channel — its failure is logged but doesn't block the alert from
    // being created, since the Firestore config below is what the app
    // itself displays (Active Targets) and evaluates in the background.
    try {
      await Supabase.instance.client.from('price_alerts').insert({
        'product_id': productId,
        'user_id': user.uid,
        'user_email': user.email,
        'target_price': targetPrice,
        'product_title': productTitle,
        'product_url': productUrl,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to save price alert to Supabase (non-fatal): $e');
    }

    // Required: this is the source of truth for the "Active Targets" tab
    // and for the background price-check (see AlertEvaluationService). If
    // this fails, the alert genuinely was not set, so let it throw.
    final config = AlertConfig(
      id: productId, // Use product ID as document ID for simple 1-to-1 alert configs
      productId: productId,
      productTitle: productTitle,
      targetPrice: targetPrice,
      currency: 'SEK',
      createdAt: DateTime.now(),
    );
    await ref.read(alertRepositoryProvider).saveAlertConfig(config);
  }
}
