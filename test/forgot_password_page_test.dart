import 'dart:async';
import 'package:dealfinder_pro/features/auth/presentation/forgot_password_page.dart';
import 'package:dealfinder_pro/features/auth/providers/auth_provider.dart';
import 'package:dealfinder_pro/features/deals/presentation/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake Auth notifier for testing
class FakeAuth extends Auth {
  FakeAuth();

  bool sendResetCalled = false;
  String? resetEmail;

  @override
  FutureOr<User?> build() => null;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    sendResetCalled = true;
    resetEmail = email;
  }
}

void main() {
  late FakeAuth fakeAuth;

  setUp(() {
    fakeAuth = FakeAuth();
  });

  // Helper to pump the widget with necessary providers
  Future<void> pumpForgotPasswordPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => fakeAuth),
        ],
        child: const MaterialApp(home: ForgotPasswordPage()),
      ),
    );
  }

  testWidgets('Forgot Password Success Screen shows correct widgets', (
    WidgetTester tester,
  ) async {
    await pumpForgotPasswordPage(tester);

    // Act: Enter an email and tap the "Send Reset Link" button
    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(); // Wait for animations and state changes

    // Assert: Verify that the success screen is now visible
    expect(fakeAuth.sendResetCalled, isTrue);
    expect(fakeAuth.resetEmail, 'test@example.com');

    // 1. Check for the success icon
    expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget);

    // 2. Check for the title and description text
    expect(find.text('Check Your Email'), findsOneWidget);
    expect(
      find.text('We have sent a password recovery link to test@example.com.'),
      findsOneWidget,
    );

    // 3. Check for the "Back to Sign In" button
    expect(
      find.widgetWithText(ElevatedButton, 'Back to Sign In'),
      findsOneWidget,
    );
  });
}
