import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api_client.dart';
import '../domain/deal.dart';

part 'recently_viewed_provider.g.dart';

@Riverpod(keepAlive: true)
class RecentlyViewedNotifier extends _$RecentlyViewedNotifier {
  static const _key = 'recently_viewed_products';
  static const _limit = 10;

  @override
  List<String> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final recentIds = prefs.getStringList(_key);
    if (recentIds != null) {
      state = recentIds;
    }
  }

  Future<void> addDeal(String dealId) async {
    // Create a mutable copy of the current state
    final updatedList = List<String>.from(state);

    // Remove the deal if it already exists to move it to the front
    updatedList.remove(dealId);

    // Add the new dealId to the beginning of the list
    updatedList.insert(0, dealId);

    // Trim the list if it exceeds the limit
    if (updatedList.length > _limit) {
      state = updatedList.sublist(0, _limit);
    } else {
      state = updatedList;
    }

    // Persist the updated list to SharedPreferences
    await _persistState();
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  /// Clears all recently viewed deals from storage and state.
  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// Resolves recently-viewed deal IDs to their [Deal] objects, most recent
/// first. Fetches just those ~10 products by id (`/api/products?ids=...`)
/// rather than depending on [dealFeedProvider]'s full-catalog fetch — that
/// full-catalog fetch is a 20MB+ response as the product count has grown,
/// and resolving a handful of ids never needed the rest of it.
@riverpod
Future<List<Deal>> recentDeals(Ref ref) async {
  final recentIds = ref.watch(recentlyViewedProvider);
  if (recentIds.isEmpty) return [];

  final response = await apiGet(
    '/api/products',
    queryParameters: {'ids': recentIds.join(',')},
  );
  final List<dynamic> data = json.decode(response.body);
  final dealMap = {
    for (final item in data)
      (item as Map<String, dynamic>)['product_id'] as String:
          Deal.fromJson(item),
  };
  return recentIds.map((id) => dealMap[id]).whereType<Deal>().toList();
}
