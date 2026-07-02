import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/favorites_repository.dart';

part 'local_favorites_notifier.g.dart';

@Riverpod(keepAlive: true)
class FavoritesNotifier extends _$FavoritesNotifier {
  @override
  Future<Set<String>> build() async {
    final user = ref.watch(authedUserProvider);
    final favoritesRepository = ref.watch(favoritesRepositoryProvider);

    // When auth state changes, re-fetch favorites.
    // This handles login/logout scenarios automatically.
    ref.listen(authedUserProvider, (previous, next) {
      if (previous?.id != next?.id) {
        ref.invalidateSelf();
      }
    });

    return favoritesRepository.getFavorites(user);
  }

  Future<void> toggleFavorite(String dealId) async {
    final user = ref.read(authedUserProvider);
    final favoritesRepository = ref.read(favoritesRepositoryProvider);

    // Optimistically update the UI
    final newFavorites = Set<String>.from(state.valueOrNull ?? {});
    if (newFavorites.contains(dealId)) {
      newFavorites.remove(dealId);
    } else {
      newFavorites.add(dealId);
    }
    state = AsyncData(newFavorites);

    // Persist the change
    await favoritesRepository.toggleFavorite(dealId, user);
  }

  bool isFavorite(String dealId) {
    return state.valueOrNull?.contains(dealId) ?? false;
  }
}
