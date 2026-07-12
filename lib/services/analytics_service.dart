import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// A singleton service for handling Google Analytics.
/// It ensures that analytics are only collected if the user has given consent.
class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;

  /// Returns true if analytics have been initialized and are enabled.
  bool get isEnabled => _analytics != null;

  /// Initializes Firebase Analytics and enables collection.
  /// This should only be called after the user has given consent.
  Future<void> enableAnalytics() async {
    if (kIsWeb && _analytics == null) {
      _analytics = FirebaseAnalytics.instance;
      // This is the key part for GDPR compliance.
      // It tells Google Analytics that it's okay to store analytics data.
      await _analytics?.setAnalyticsCollectionEnabled(true);
      debugPrint('[AnalyticsService] Analytics collection enabled.');
      logEvent(name: 'consent_accepted');
    }
  }

  /// Disables analytics collection.
  Future<void> disableAnalytics() async {
    if (kIsWeb && _analytics != null) {
      await _analytics?.setAnalyticsCollectionEnabled(false);
      debugPrint('[AnalyticsService] Analytics collection disabled.');
      _analytics = null;
    }
  }

  /// Logs a custom event to Google Analytics.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!isEnabled) return;
    await _analytics?.logEvent(name: name, parameters: parameters);
  }

  /// Fires GA4's `product_click` event — a user tapping a deal card or a
  /// deal's "Get Deal" button, i.e. an outbound affiliate click. Takes
  /// primitive fields rather than a `Deal` so this service (in `lib/services`)
  /// doesn't need to depend on `lib/features/deals`' domain model.
  Future<void> trackProductClick({
    required String itemId,
    required String itemName,
    required String itemBrand,
    required double price,
    required String currency,
  }) async {
    await logEvent(
      name: 'product_click',
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'item_brand': itemBrand,
        'price': price,
        'currency': currency,
      },
    );
  }

  /// Fires GA4's `newsletter_signup` event on a successful signup submit.
  Future<void> trackNewsletterSignup() async {
    await logEvent(name: 'newsletter_signup');
  }
}
