import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  User? build() {
    final sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      state = user;
    });
    ref.onDispose(sub.cancel);
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> signInWithEmail(String email, String password) =>
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<void> createAccount(String email, String password) =>
      FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<void> signOut() => FirebaseAuth.instance.signOut();
}
