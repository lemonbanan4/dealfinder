1import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealfinder_pro/features/deals/presentation/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dealfinder_pro/features/auth/providers/auth_provider.dart';

part 'favorites_repository.g.dart';

const _localFavoritesKey = 'local_favorite_deals';

/// A repository to manage user's favorite deals, syncing between
/// local preferences and Firestore for authenticated users.
@riverpod
FavoritesRepository favoritesRepository(FavoritesRepositoryRef ref) {
  return FavoritesRepository(FirebaseFirestore.instance, ref);
}

class FavoritesRepository {
  FavoritesRepository(this._firestore, this._ref);

  final FirebaseFirestore _firestore;
  final Ref _ref;

  DocumentReference<Map<String, dynamic>>? _userFavoritesDoc(User? user) {
    if (user == null) return null;
    return _firestore.collection('users').doc(user.id);
  }

  /// Fetches favorites. If a user is logged in, it syncs from Firestore
  /// to local storage first, then returns the local data.
  Future<Set<String>> getFavorites(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    final localFavorites =
        prefs.getStringList(_localFavoritesKey)?.toSet() ?? {};

    if (user != null) {
      try {
        final doc = await _userFavoritesDoc(user)!.get();
        final remoteData = doc.data();
        final remoteFavorites =
            remoteData != null && remoteData.containsKey('favorites')
            ? List<String>.from(remoteData['favorites']).toSet()
            : <String>{};

        // Merge local and remote, giving remote precedence for the initial sync.
        final mergedFavorites = localFavorites.union(remoteFavorites);

        if (mergedFavorites.isNotEmpty) {
          // Write the merged set back to both sources to ensure they are in sync.
          await prefs.setStringList(
            _localFavoritesKey,
            mergedFavorites.toList(),
          );
          await _userFavoritesDoc(user)!.set({
            'favorites': mergedFavorites.toList(),
          }, SetOptions(merge: true));
        }
        return mergedFavorites;
      } catch (e) {
        debugPrint('Failed to load/sync favorites from Firestore: $e');
        // Fallback to local prefs if Firestore fails.
        return localFavorites;
      }
    }
    // For logged-out users, just return local favorites.
    return localFavorites;
  }

  /// Toggles a favorite and persists the change to local storage and
  /// Firestore (if the user is authenticated).
  Future<void> toggleFavorite(String dealId, User? user) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFavorites =
        prefs.getStringList(_localFavoritesKey)?.toSet() ?? {};

    final newFavorites = Set<String>.from(currentFavorites);
    if (newFavorites.contains(dealId)) {
      newFavorites.remove(dealId);
    } else {
      newFavorites.add(dealId);
    }

    // Always update local storage for immediate offline access.
    await prefs.setStringList(_localFavoritesKey, newFavorites.toList());

    // If the user is logged in, also update Firestore.
    if (user != null) {
      await _userFavoritesDoc(
        user,
      )!.set({'favorites': newFavorites.toList()}, SetOptions(merge: true));
    }
  }

  /// Clears local favorites. Called on user sign-out to prevent
  /// one user's local favorites from leaking to the next.
  Future<void> clearLocalFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localFavoritesKey);
  }
}

/// A simple provider to expose the user object from the authProvider
@riverpod
User? authedUser(Ref ref) {
  return ref.watch(authProvider).value;
}
