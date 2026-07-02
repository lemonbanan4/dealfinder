import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/user.dart';

/// An authentication repository that interacts with Firebase Authentication.
///
/// Note: Google Sign-In is handled via Firebase's built-in popup/redirect flow
/// on web. For native iOS/Android add google_sign_in to pubspec.yaml and
/// uncomment the GoogleSignIn code below.
class AuthRepository {
  AuthRepository(this._firebaseAuth);

  final fb.FirebaseAuth _firebaseAuth;

  /// Maps the Firebase User stream to our custom User model.
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
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
    await _firebaseAuth.signOut();
  }

  /// Signs in with Google via Firebase popup (web) or redirect (native).
  /// For native platforms add `google_sign_in` to pubspec.yaml.
  Future<void> signInWithGoogle() async {
    final provider = fb.GoogleAuthProvider();
    try {
      await _firebaseAuth.signInWithPopup(provider);
    } catch (_) {
      // Popup was blocked or user cancelled — try redirect as fallback
      await _firebaseAuth.signInWithRedirect(provider);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(fb.FirebaseAuth.instance);
});
