import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../deals/data/favorites_repository.dart';
import '../data/auth_repository.dart';
import '../domain/user.dart';
import '../../deals/providers/favorites_provider.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  late final StreamSubscription<User?> _authStateChangesSubscription;

  @override
  FutureOr<User?> build() {
    final authRepository = ref.watch(authRepositoryProvider);

    _authStateChangesSubscription = authRepository.authStateChanges().listen(
      (user) {
        state = AsyncData(user);
      },
      onError: (err, stack) {
        state = AsyncError(err, stack);
      },
    );

    ref.onDispose(() {
      _authStateChangesSubscription.cancel();
    });

    final firebaseUser = fb.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        emailVerified: firebaseUser.emailVerified,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        providerData: firebaseUser.providerData,
      );
    }
    return null;
  }

  Future<void> _runAuthMethod(Future<void> Function() method) async {
    state = const AsyncLoading();
    try {
      await method();
      // The stream listener will automatically set the AsyncData state on success.
    } on fb.FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      } else {
        message = 'An error occurred. Please try again.';
      }
      state = AsyncError(message, e.stackTrace ?? StackTrace.current);
    } catch (e, st) {
      state = AsyncError('An unexpected error occurred.', st);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _runAuthMethod(
      () => ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email, password),
    );
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await _runAuthMethod(
      () => ref
          .read(authRepositoryProvider)
          .signUpWithEmailAndPassword(email, password),
    );
  }

  Future<void> signInWithGoogle() async =>
      _runAuthMethod(ref.read(authRepositoryProvider).signInWithGoogle);

  Future<void> signInWithApple() async =>
      _runAuthMethod(ref.read(authRepositoryProvider).signInWithApple);

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    } on fb.FirebaseAuthException catch (e) {
      throw 'Could not send reset email: ${e.message}';
    }
  }

  Future<void> signOut() async {
    // Clear local favorites before signing out so they don't leak to next user
    await ref.read(favoritesRepositoryProvider).clearLocalFavorites();
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidate(favoritesProvider);
  }

  Future<void> deleteAccount() async {
    await _runAuthMethod(() async {
      await fb.FirebaseAuth.instance.currentUser?.delete();
    });
  }

  Future<void> updateUserName(String newName) async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(newName);
      ref.invalidateSelf();
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }
}
