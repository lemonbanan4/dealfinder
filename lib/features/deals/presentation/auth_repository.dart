import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/user.dart';

/// An authentication repository that interacts with Firebase Authentication.
class AuthRepository {
  AuthRepository(this._firebaseAuth)
      // Bug 8 / Improvement 9 fix: GoogleSignIn must be a persistent field,
      // not instantiated inline. A new instance on every call can fail on iOS
      // because the platform channel expects the same object that was registered.
      : _googleSignIn = GoogleSignIn();

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Maps the Firebase User stream to our custom User model.
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return User(id: firebaseUser.uid, email: firebaseUser.email);
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
    // Sign out from both Firebase and Google so the account picker
    // shows on the next sign-in attempt.
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> signInWithGoogle() async {
    // Reuse the persistent _googleSignIn instance — critical on iOS
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // The user cancelled the sign-in
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(fb.FirebaseAuth.instance);
});
