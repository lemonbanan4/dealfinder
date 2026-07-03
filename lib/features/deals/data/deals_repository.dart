import 'dart:convert';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../presentation/deals_notifier.dart';
import '../domain/deal.dart';



/// A repository for fetching deals from an API.
class DealsRepository {
  DealsRepository({http.Client? client, FirebaseAppCheck? appCheck})
      : _client = client ?? http.Client(),
        _appCheck = appCheck;

  final http.Client _client;
  final FirebaseAppCheck? _appCheck;

  Future<String?> _maybeGetAppCheckToken() async {
    try {
      return await FirebaseAppCheck.instance.getToken(true);
    } catch (_) {
      return 'test-token';
    }
  }

  /// This is where you'd fetch from your actual API.
  /// We're using a mock API for demonstration.
  Future<List<Deal>> fetchDeals({
    required int
    page, // `page` is not used by the scraper yet, but good to keep
    String? query,
    DealSort? sort,
    String? category,
  }) async {
    // Use the new deployed service URL
    const String baseUrl =
        'https://scraper-api-service-838381255973.europe-north1.run.app/deals';

    // Get the App Check token to send in the header
    final appCheckToken = _appCheck != null
        ? await _appCheck.getToken(true)
        : await _maybeGetAppCheckToken();

    if (appCheckToken == null) {
      throw Exception('Could not get App Check token.');
    }

    final headers = {'X-Firebase-AppCheck': appCheckToken};

    // Note: Your current scraper doesn't support query/sort/category.
    // When it does, you'll pass them as query parameters here.
    final uri = Uri.parse(baseUrl);
    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Map the response from your scraper to the Deal model.
      return data.map((json) {
        return Deal(
          id: json['product_id'],
          title: json['title'],
          source: json['brand'],
          url: json['tracking_url'],
          imageUrl: json['image_url'],
          currentPrice: (json['price'] as num).toDouble(),
          // Your scraper doesn't provide these yet, so we'll use placeholders.
          originalPrice: (json['price'] as num).toDouble() * 1.2,
          currency: 'SEK',
        );
      }).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid App Check token.');
    } else {
      throw Exception(
        'Failed to load deals. Status code: ${response.statusCode}',
      );
    }
  }
}

/// Provider for the DealsRepository.
final dealsRepositoryProvider = Provider<DealsRepository>((ref) {
  return DealsRepository();
});
