import 'package:dio/dio.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/deals/domain/deal.dart';
import '../features/deals/presentation/deals_notifier.dart';

class DealApiService {
  final Dio _dio;
  // The URL from your deployment output
  static const String _baseUrl =
      'https://scraper-api-service-838381255973.europe-north1.run.app';

  DealApiService({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  /// Fetches deals from your scraper API.
  ///
  /// Includes parameters for sorting and filtering as we discussed.
  Future<List<Deal>> fetchDeals({DealSort? sort, String? query}) async {
    // Convert DealSort enum to the string your API expects
    final appCheckToken = await FirebaseAppCheck.instance.getToken(true);
    if (appCheckToken == null) {
      // Or handle this more gracefully, maybe return an empty list or a custom error
      throw Exception('Could not get App Check token.');
    }

    final options = Options(headers: {'X-Firebase-AppCheck': appCheckToken});

    final queryParameters = <String, dynamic>{
      'sort_by': sort?.toApiKey(),
      'order': sort?.toApiOrder(),
      'q': query,
    }..removeWhere((key, value) => value == null);

    final response = await _dio.get<List<dynamic>>(
      '/deals',
      queryParameters: queryParameters,
      options: options,
    );
    // Use the fromJson factory from your actual Deal model
    return response.data?.map((json) => Deal.fromJson(json)).toList() ?? [];
  }
}

/// Provider for the DealApiService.
final dealApiServiceProvider = Provider<DealApiService>((ref) {
  return DealApiService();
});

/// A record to hold the parameters for fetching deals.
typedef DealRequest = ({String? query, DealSort sort});

/// FutureProvider to fetch deals from the API.
///
/// This replaces the need for a complex StateNotifier for simple fetching.
/// It will automatically handle loading/error/data states and re-fetch
/// when its parameters (query or sort) change.
final dealsProvider = FutureProvider.autoDispose
    .family<List<Deal>, DealRequest>((ref, request) {
      final apiService = ref.watch(dealApiServiceProvider);
      return apiService.fetchDeals(query: request.query, sort: request.sort);
    });

// Helper extension to convert the enum to API-compatible strings
extension on DealSort {
  String toApiKey() {
    return this == DealSort.relevance ? 'last_updated' : 'price';
  }

  String toApiOrder() {
    if (this == DealSort.priceAsc) return 'asc';
    return 'desc'; // For relevance and priceDesc
  }
}
