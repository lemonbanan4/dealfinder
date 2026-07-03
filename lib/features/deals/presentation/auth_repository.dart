import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;

import '../presentation/user.dart';

/// An authentication repository that interacts with Firebase Authentication.
///
/// Google Sign-In branches by platform: web uses Firebase's built-in
/// popup/redirect flow (no extra config needed), while native iOS/Android
/// go through the `google_sign_in` plugin and exchange its ID token for a
/// Firebase credential, since `signInWithPopup`/`signInWithRedirect` are
/// web-only APIs.
class AuthRepository {
  AuthRepository(this._firebaseAuth);

  final fb.FirebaseAuth _firebaseAuth;

  /// Maps the Firebase User stream to our custom User model.
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        emailVerified: firebaseUser.emailVerified,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        providerData: firebaseUser.providerData,
      );
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Signs in with Google: popup (falling back to redirect) on web, or the
  /// native `google_sign_in` + credential exchange flow on iOS/Android.
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = fb.GoogleAuthProvider();
      try {
        await _firebaseAuth.signInWithPopup(provider);
      } catch (_) {
        // Popup was blocked or user cancelled — try redirect as fallback
        await _firebaseAuth.signInWithRedirect(provider);
      }
      return;
    }

    final account = await google.GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
    await _firebaseAuth.signInWithCredential(credential);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(fb.FirebaseAuth.instance);
});
