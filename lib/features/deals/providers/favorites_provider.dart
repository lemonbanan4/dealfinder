import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/analytics_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/favorites_repository.dart';
import '../domain/deal.dart';

part 'favorites_provider.g.dart';

@Riverpod(keepAlive: true)
class FavoritesNotifier extends _$FavoritesNotifier {
  @override
  Future<Set<String>> build() async {
    final user = ref.watch(authProvider).value;
    final favoritesRepository = ref.watch(favoritesRepositoryProvider);

    // When auth state changes, re-fetch favorites.
    // This handles login/logout scenarios automatically.
    ref.listen(authProvider, (previous, next) {
      if (previous?.value?.id != next.value?.id) {
        ref.invalidateSelf();
      }
    });

    return favoritesRepository.getFavorites(user);
  }

  Future<void> handleFavoriteTap(BuildContext context, Deal deal) async {
    final user = ref.read(authProvider).value;
    if (user != null && !user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email to manage favorites.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    AnalyticsService().logEvent(
      name: 'toggle_favorite',
      parameters: {'deal_id': deal.id},
    );
    try {
      await toggleFavorite(deal.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update favorite.')),
        );
      }
    }
  }

  /// Clears all favorites from storage and state.
  Future<void> clear() async {
    final repo = ref.read(favoritesRepositoryProvider);
    final user = ref.read(authProvider).value;
    await repo.clearFavorites(user);
    state = const AsyncValue.data({});
  }

  Future<void> toggleFavorite(String productId) async {
    final user = ref.read(authProvider).value;
    final repo = ref.read(favoritesRepositoryProvider);

    final previousState = state;
    if (state.hasValue) {
      final newFavs = Set<String>.from(state.value!);
      if (newFavs.contains(productId)) {
        newFavs.remove(productId);
      } else {
        newFavs.add(productId);
      }
      state = AsyncValue.data(newFavs);
    }

    try {
      await repo.toggleFavorite(productId, user);
    } catch (e, st) {
      // Revert to the previous state on error
      state = previousState;
      // Log the error
      log(
        'Failed to toggle favorite for product $productId',
        name: 'FavoritesNotifier',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }



  bool isFavorite(String dealId) {
    return state.value?.contains(dealId) ?? false;
  }
}
