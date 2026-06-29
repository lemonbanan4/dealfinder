import 'package:dealfinder_pro/features/auth/presentation/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks for Firebase Auth
class MockGlobalKey extends Mock implements GlobalKey<FormState> {}

class MockFormState extends Mock implements FormState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

// A mock for FirebaseAuthException since it's not easily instantiable.
class MockFirebaseAuthException extends Mock implements FirebaseAuthException {
  @override
  final String message = 'An error occurred.';
}

void main() {
  // Use late to initialize in setUp
  late MockFirebaseAuth mockAuth;
  late ProviderContainer container;
  late MockFormState mockFormState;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFormState = MockFormState();

    when(() => mockFormState.validate()).thenReturn(true);

    // Create a new ProviderContainer for each test.
    container = ProviderContainer(
      overrides: [
        // Override the loginProvider to use the mock FirebaseAuth instance.
        loginProvider.overrideWith(() => LoginNotifier(mockAuth)),
      ],
    );

    // Mock the user object
    final mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('test_uid');
    when(() => mockUser.email).thenReturn('test@test.com');

    // Mock the user credential
    final mockUserCredential = MockUserCredential();
    when(() => mockUserCredential.user).thenReturn(mockUser);

    // Stub the auth methods to return successful results
    when(
      () => mockAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => mockUserCredential);

    when(
      () => mockAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => mockUserCredential);

    when(
      () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
    ).thenAnswer((_) async => {});
  });

  tearDown(() {
    container.dispose();
  });

  group('LoginNotifier', () {
    test('initial state is correct', () {
      final state = container.read(loginProvider);
      expect(state.isLogin, true);
      expect(state.loading, false);
      expect(state.obscurePass, true);
      expect(state.error, null);
    });

    test('toggleMode switches between login and signup', () {
      final notifier = container.read(loginProvider.notifier);

      // Initial state is login
      expect(container.read(loginProvider).isLogin, true);

      // Toggle to signup
      notifier.toggleMode();
      expect(container.read(loginProvider).isLogin, false);

      // Toggle back to login
      notifier.toggleMode();
      expect(container.read(loginProvider).isLogin, true);
    });

    test('toggleObscure toggles password visibility', () {
      final notifier = container.read(loginProvider.notifier);
      expect(container.read(loginProvider).obscurePass, true);
      notifier.toggleObscure();
      expect(container.read(loginProvider).obscurePass, false);
    });

    // This test assumes you have a way to inject MockFirebaseAuth
    // into your LoginNotifier.
    test(
      'submit calls signInWithEmailAndPassword when in login mode',
      () async {
        final notifier = container.read(loginProvider.notifier);
        final mockFormKey = MockGlobalKey();
        when(() => mockFormKey.currentState).thenReturn(mockFormState);

        await notifier.submit(mockFormKey, 'test@test.com', 'password');

        verify(
          () => mockAuth.signInWithEmailAndPassword(
            email: 'test@test.com',
            password: 'password',
          ),
        ).called(1);

        verifyNever(
          () => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    test(
      'submit calls createUserWithEmailAndPassword when in signup mode',
      () async {
        final notifier = container.read(loginProvider.notifier);
        final mockFormKey = MockGlobalKey();
        when(() => mockFormKey.currentState).thenReturn(mockFormState);

        // Switch to signup mode
        notifier.toggleMode();

        await notifier.submit(mockFormKey, 'test@test.com', 'password');

        verify(
          () => mockAuth.createUserWithEmailAndPassword(
            email: 'test@test.com',
            password: 'password',
          ),
        ).called(1);

        verifyNever(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    group('resetPassword', () {
      test('sets error state if email is invalid', () async {
        final notifier = container.read(loginProvider.notifier);

        await notifier.resetPassword('invalid-email');

        final state = container.read(loginProvider);
        expect(state.error, 'Please enter a valid email.');
        expect(state.loading, false);
        verifyNever(
          () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
        );
      });

      test('calls sendPasswordResetEmail and sets state on success', () async {
        final notifier = container.read(loginProvider.notifier);
        const email = 'test@example.com';

        // The `setUp` already stubs this for success.
        await notifier.resetPassword(email);

        verify(() => mockAuth.sendPasswordResetEmail(email: email)).called(1);

        final state = container.read(loginProvider);
        expect(state.loading, false);
        expect(state.resetEmailSent, true);
        expect(state.error, isNull);
      });

      test('sets error state on FirebaseAuthException', () async {
        final exception = MockFirebaseAuthException();
        when(
          () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
        ).thenThrow(exception);

        final notifier = container.read(loginProvider.notifier);
        await notifier.resetPassword('test@example.com');

        final state = container.read(loginProvider);
        expect(state.loading, false);
        expect(state.resetEmailSent, false);
        expect(state.error, exception.message);
      });

      test('sets generic error state on other exceptions', () async {
        when(
          () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
        ).thenThrow(Exception('Network error'));

        final notifier = container.read(loginProvider.notifier);
        await notifier.resetPassword('test@example.com');

        final state = container.read(loginProvider);
        expect(state.loading, false);
        expect(state.resetEmailSent, false);
        expect(state.error, 'An unexpected error occurred.');
      });
    });
  });
}
