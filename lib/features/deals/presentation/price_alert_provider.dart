import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants.dart';
import '../../alerts/domain/alert_config.dart';
import '../../alerts/providers/alert_configs_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'feed_page.dart' show regionProvider;

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
    required double targetPrice,
  }) async {
    // This notifier is autoDispose and the caller only ever `ref.read`s it
    // (never `watch`es it), so without this link Riverpod disposes it as
    // soon as this synchronous call stack returns — tearing down `ref` while
    // the awaits below are still in flight and throwing "used after dispose".
    final keepAliveLink = ref.keepAlive();
    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        throw Exception('You must be signed in to set a price alert.');
      }
      if (!user.emailVerified) {
        throw Exception('Please verify your email to set price alerts.');
      }

      // Firestore's security rules (and the backend endpoint below) re-check
      // email verification against the ID token's own `email_verified`
      // claim, which can lag behind the client's cached `emailVerified` flag
      // until the token is refreshed — e.g. right after the user verifies
      // their email in the same session. Force a refresh so a
      // freshly-verified user isn't rejected.
      final idToken = await fb.FirebaseAuth.instance.currentUser?.getIdToken(
        true,
      );

      // Best-effort: also save to the backend's price_alerts table for the
      // scraper's server-side email-alert check. This is a secondary
      // notification channel — its failure is logged but doesn't block the
      // alert from being created, since the Firestore config below is what
      // the app itself displays (Active Targets) and evaluates in the
      // background. Routed through the backend (rather than Supabase
      // directly) since this table holds other users' emails — the backend
      // verifies the Firebase ID token and scopes the write to that uid,
      // instead of relying on Supabase RLS, which has no way to know who's
      // calling when the client only ever authenticates via Firebase.
      try {
        final response = await http.post(
          Uri.parse('${ApiUrls.apiUrl}/api/alerts'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'product_id': productId,
            'product_title': productTitle,
            'target_price': targetPrice,
            'region': ref.read(regionProvider),
          }),
        );
        if (response.statusCode >= 400) {
          throw Exception(
            'Backend rejected the alert (${response.statusCode}): ${response.body}',
          );
        }
      } catch (e) {
        debugPrint('Failed to save price alert to backend (non-fatal): $e');
      }

      // Required: this is the source of truth for the "Active Targets" tab.
      // If this fails, the alert genuinely was not set, so let it throw.
      final config = AlertConfig(
        id: productId, // Use product ID as document ID for simple 1-to-1 alert configs
        productId: productId,
        productTitle: productTitle,
        targetPrice: targetPrice,
        currency: 'SEK',
        createdAt: DateTime.now(),
      );
      await ref.read(alertRepositoryProvider).saveAlertConfig(config);
    } finally {
      keepAliveLink.close();
    }
  }
}
