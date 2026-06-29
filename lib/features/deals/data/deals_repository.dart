import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/deal.dart';

const _dealsPerPage = 20;

/// A repository for fetching deals from an API.
class DealsRepository {
  DealsRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// This is where you'd fetch from your actual API.
  /// We're using a mock API for demonstration.
  Future<List<Deal>> fetchDeals({required int page}) async {
    // Using a free mock API for demonstration.
    // Replace this with your actual API endpoint.
    final uri = Uri.parse(
      'https://jsonplaceholder.typicode.com/photos?_page=$page&_limit=$_dealsPerPage',
    );
    // Use the injected client
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) {
        final id = json['id'].toString();
        return Deal(
          id: 'deal_$id',
          title: json['title'],
          source: 'JSONPlaceholder',
          url: json['url'],
          imageUrl: json['thumbnailUrl'],
          currentPrice: (json['id'] as int) * 1.5,
          originalPrice: (json['id'] as int) * 2.0,
          currency: 'USD',
        );
      }).toList();
    } else {
      throw Exception('Failed to load deals from API');
    }
  }
}

/// Provider for the DealsRepository.
final dealsRepositoryProvider = Provider<DealsRepository>((ref) {
  return DealsRepository();
});
