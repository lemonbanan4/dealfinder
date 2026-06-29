import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StreamNotifierProvider<AuthProvider, User?>(
  AuthProvider.new,
);

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

class AuthProvider extends StreamNotifier<User?> {
  @override
  Stream<User?> build() {
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    // Assuming you have an edge function or similar to delete user data.
    // This part would need to be implemented.
    // e.g., await ref.read(functionsProvider).httpsCallable('deleteUser').call();
    await FirebaseAuth.instance.currentUser?.delete();
    await signOut();
  }

  Future<void> updateUserName(String newName) async {
    final user = state.value;
    if (user == null) throw Exception('User not logged in');

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await user.updateDisplayName(newName);
      // The authStateChanges stream will emit a new user object,
      // but we can also return it here for immediate UI update.
      await user.reload();
      return FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> updatePassword(String newPassword) async {
    final user = state.value;
    if (user == null) throw Exception('User not logged in');

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await user.updatePassword(newPassword);
      // The authStateChanges stream will emit the new user object after reload.
      await user.reload();
      // We return the reloaded user for immediate feedback, though the stream will also update.
      return FirebaseAuth.instance.currentUser;
    });
    // Re-throw the error on failure to be caught by the UI
    state.whenOrNull(error: (e, s) => throw e);
  }
}
