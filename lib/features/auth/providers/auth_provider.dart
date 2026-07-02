import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealfinder_pro/features/deals/data/favorites_repository.dart';

import '../../deals/presentation/auth_repository.dart';
import '../../deals/presentation/user.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this._authRepository, this._ref) : super(const AsyncLoading()) {
    _authStateChangesSubscription = _authRepository.authStateChanges().listen(
      (user) {
        state = AsyncData(user);
      },
    );
  }

  final AuthRepository _authRepository;
  // Fix: store ref so signOut can invalidate providers
  final Ref _ref;
  late final StreamSubscription<User?> _authStateChangesSubscription;

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
      () => _authRepository.signInWithEmailAndPassword(email, password),
    );
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await _runAuthMethod(
      () => _authRepository.signUpWithEmailAndPassword(email, password),
    );
  }

  Future<void> signInWithGoogle() async =>
      _runAuthMethod(_authRepository.signInWithGoogle);

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } on fb.FirebaseAuthException catch (e) {
      throw 'Could not send reset email: ${e.message}';
    }
  }

  Future<void> signOut() async {
    // Clear local favorites before signing out so they don't leak to next user
    await _ref.read(favoritesRepositoryProvider).clearLocalFavorites();
    await _authRepository.signOut();
    _ref.invalidate(favoritesNotifierProvider);
  }

  Future<void> deleteAccount() async {
    await _runAuthMethod(() async {
      await fb.FirebaseAuth.instance.currentUser?.delete();
    });
  }

  @override
  void dispose() {
    _authStateChangesSubscription.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((
  ref,
) {
  // Pass ref into notifier so it can read/invalidate other providers
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});
