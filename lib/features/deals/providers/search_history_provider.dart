import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_history_provider.g.dart';

const _kSearchHistoryKey = 'search_history';
const _kMaxHistorySize = 15;

@Riverpod(keepAlive: true)
class SearchHistory extends _$SearchHistory {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kSearchHistoryKey) ?? [];
  }

  Future<void> add(String query) async {
    final lowerCaseQuery = query.toLowerCase().trim();
    if (lowerCaseQuery.isEmpty) return;

    final currentHistory = List<String>.from(state.value ?? []);

    // Remove if it already exists to move it to the top
    currentHistory.removeWhere((item) => item.toLowerCase() == lowerCaseQuery);

    // Add to the top
    final updatedHistory = [lowerCaseQuery, ...currentHistory];

    // Trim the list if it's too long
    if (updatedHistory.length > _kMaxHistorySize) {
      updatedHistory.removeRange(_kMaxHistorySize, updatedHistory.length);
    }

    // Persist and update state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kSearchHistoryKey, updatedHistory);
    state = AsyncData(updatedHistory);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSearchHistoryKey);
    state = const AsyncData([]);
  }
}
