import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/providers/auth_provider.dart';

/// A repository to manage user's favorite deals, syncing between
/// local preferences and Firestore for authenticated users.
class FavoritesRepository {
  FavoritesRepository(this._prefs, this._firestore, this.ref);

  final Ref ref;
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;

  static const _key = 'favorite_products_pref';

  /// Fetches favorites. If a user is logged in, it syncs from Firestore
  /// to local storage first, then returns the local data.
  Future<Set<String>> getFavorites(User? user) async {
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data.containsKey('favorites')) {
            final firestoreFavs = List<String>.from(data['favorites']);
            // Sync to local prefs for offline access and consistency.
            await _prefs.setStringList(_key, firestoreFavs);
            return firestoreFavs.toSet();
          }
        }
      } catch (e) {
        debugPrint('Failed to load favorites from Firestore: $e');
        // Fallback to local prefs if Firestore fails.
      }
    }
    // For logged-out users or on Firestore error, load from local prefs.
    return _prefs.getStringList(_key)?.toSet() ?? {};
  }

  /// Toggles a favorite and persists the change to local storage and
  /// Firestore (if the user is authenticated).
  Future<Set<String>> toggleFavorite(String productId, User? user) async {
    final currentFavs = _prefs.getStringList(_key)?.toSet() ?? {};
    final newFavs = Set<String>.from(currentFavs);

    if (newFavs.contains(productId)) {
      newFavs.remove(productId);
    } else {
      newFavs.add(productId);
    }

    await _prefs.setStringList(_key, newFavs.toList());

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'favorites': newFavs.toList(),
      }, SetOptions(merge: true));
    }
    return newFavs;
  }

  /// Clears all favorites from local storage and Firestore.
  Future<void> clearFavorites(User? user) async {
    await _prefs.remove(_key);
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'favorites': [],
      }, SetOptions(merge: true));
    }
  }
}

// Build the repository using a FutureProvider so it has access to the SharedPreferences and Firestore instances.
final favoritesRepositoryProvider = FutureProvider<FavoritesRepository>((
  ref,
) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final firestore = ref.watch(firestoreProvider);
  return FavoritesRepository(prefs, firestore, ref);
});
