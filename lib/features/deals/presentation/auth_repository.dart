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
    if (!kIsWeb) {
      // Also sign out of the native Google session so the account picker
      // reappears next time, instead of silently re-authenticating with
      // whichever Google account was used last.
      await google.GoogleSignIn.instance.signOut();
    }
  }

  /// Signs in with Google: popup (falling back to redirect) on web, or the
  /// native `google_sign_in` + credential exchange flow on iOS/Android.
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = fb.GoogleAuthProvider()
        // Without this, Google silently skips the account chooser and
        // signs in with whichever single Google account is already active
        // in the browser profile instead of letting the user pick.
        ..setCustomParameters({'prompt': 'select_account'});
      try {
        await _firebaseAuth.signInWithPopup(provider);
      } on fb.FirebaseAuthException catch (e) {
        // Only a genuinely blocked popup should fall back to a full-page
        // redirect. Treating every failure (including the user simply
        // closing the popup) as "blocked" forces an unwanted redirect.
        if (e.code == 'popup-blocked') {
          await _firebaseAuth.signInWithRedirect(provider);
        } else if (e.code == 'popup-closed-by-user' ||
            e.code == 'cancelled-popup-request') {
          return;
        } else {
          rethrow;
        }
      }
      return;
    }

    final account = await google.GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
    await _firebaseAuth.signInWithCredential(credential);
  }

  /// Signs in with Apple — web only, via Firebase's built-in OAuth popup
  /// flow (same mechanism as [signInWithGoogle]'s web branch). Deliberately
  /// doesn't use the native `sign_in_with_apple` package: this app only
  /// ships to web (see CLAUDE.md's Commands — `flutter build web`/`firebase
  /// deploy`, no App Store pipeline), and that package's web implementation
  /// is itself just a wrapper around the same Apple JS SDK popup Firebase
  /// already drives directly, so pulling it in would only add unused native
  /// (iOS/Android) code and WASM-incompatible JS interop to the web bundle
  /// for zero benefit. If this app ever ships to iOS, native Apple Sign-In
  /// there requires that package (Apple's App Store guidelines mandate the
  /// native flow, not a web popup) — add it back specifically for that.
  Future<void> signInWithApple() async {
    assert(kIsWeb, 'signInWithApple is web-only — see the doc comment.');
    final provider = fb.OAuthProvider('apple.com')
      ..addScope('email')
      ..addScope('name');
    try {
      await _firebaseAuth.signInWithPopup(provider);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'popup-blocked') {
        await _firebaseAuth.signInWithRedirect(provider);
      } else if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return;
      } else {
        rethrow;
      }
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(fb.FirebaseAuth.instance);
});
