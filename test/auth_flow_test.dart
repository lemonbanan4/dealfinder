import 'package:dealfinder_pro/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Define screen sizes to test
  final aPhone = const Size(414, 896); // iPhone 11 Pro Max
  final aTablet = const Size(1024, 1366); // iPad Pro 12.9"

  void runAuthFlowTest(Size size) {
    testWidgets(
      'Full sign-in and sign-out flow on ${size.width}x${size.height}',
      (WidgetTester tester) async {
        // Set the screen size for this test
        await tester.binding.setSurfaceSize(size);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        // Start the app
        app.main();
        await tester.pumpAndSettle();

        // For this example, we assume the user is initially signed out.
        // Navigate to the profile/auth page.
        await tester.tap(find.byIcon(Icons.person_outline));
        await tester.pumpAndSettle();

        // We should be on the sign-in prompt page now.
        expect(find.text('Sign In or Create Account'), findsOneWidget);
        await tester.tap(find.text('Sign In or Create Account'));
        await tester.pumpAndSettle();

        // Now on the SignInPage
        expect(find.widgetWithText(AppBar, 'Sign In'), findsOneWidget);

        // Enter email and password.
        // NOTE: Use a real test account from your Firebase project.
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'test@example.com', // Use a valid test user
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'password', // Use the correct password
        );

        // Tap the sign-in button.
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.pumpAndSettle(
          const Duration(seconds: 3), // Wait for Firebase auth to complete
        );

        // After signing in, we should be back on the profile page, now showing user details.
        expect(find.text('test@example.com'), findsOneWidget);

        // Now, let's test sign-out.
        await tester.tap(find.text('Sign Out'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // We should be back on the auth prompt screen.
        expect(find.text('Sign In or Create Account'), findsOneWidget);
      },
      skip: true,
    ); // Skipping because it requires a real Firebase user. Remove 'skip: true' to run.
  }

  group('Authentication Flow on different screen sizes', () {
    runAuthFlowTest(aPhone);
    runAuthFlowTest(aTablet);
  });
}
