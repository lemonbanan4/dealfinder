import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/deal.dart';
import 'deals_provider.dart';

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
/// first. A real top-level provider — not one built fresh inside a widget's
/// `build()` (the previous approach), which registers a brand-new, never-
/// disposed provider instance in the container on every rebuild.
@riverpod
AsyncValue<List<Deal>> recentDeals(Ref ref) {
  final recentIds = ref.watch(recentlyViewedProvider);
  if (recentIds.isEmpty) return const AsyncValue.data([]);

  return ref
      .watch(dealFeedProvider)
      .when(
        data: (allDeals) {
          final dealMap = {for (final deal in allDeals) deal.id: deal};
          final recentDeals = recentIds
              .map((id) => dealMap[id])
              .whereType<Deal>()
              .toList();
          return AsyncValue.data(recentDeals);
        },
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
      );
}
