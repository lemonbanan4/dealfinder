import 'package:dealfinder_pro/features/auth/domain/user.dart';
import 'package:dealfinder_pro/features/auth/providers/auth_provider.dart';
import 'package:dealfinder_pro/features/deals/presentation/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks.dart';

void main() {
  // A mock user for testing the logged-in state
  const mockUser = User(id: '123', email: 'test@example.com');

  // Helper to pump the ProfilePage with a given auth state
  Future<void> pumpProfilePage(
    WidgetTester tester,
    AsyncValue<User?> authState,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the authProvider to return a specific state
          authProvider.overrideWith((ref) => MockAuthNotifier(authState)),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
  }

  group('ProfilePage', () {
    testWidgets('shows auth prompt when user is logged out', (tester) async {
      // Arrange: Set the auth state to logged-out (AsyncData(null))
      await pumpProfilePage(tester, const AsyncData(null));

      // Assert: Verify the "Sign In" button and prompt text are visible
      expect(
        find.text('Sign in to save favorites and manage your profile.'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Sign In or Create Account'),
        findsOneWidget,
      );

      // Verify user details are not present
      expect(find.text('test@example.com'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Sign Out'), findsNothing);
    });

    testWidgets('shows user profile when user is logged in', (tester) async {
      // Arrange: Set the auth state to logged-in with a mock user
      await pumpProfilePage(tester, const AsyncData(mockUser));

      // Assert: Verify the user's email and the "Sign Out" button are visible
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Sign Out'), findsOneWidget);

      // Verify the auth prompt is not present
      expect(
        find.text('Sign in to save favorites and manage your profile.'),
        findsNothing,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Sign In or Create Account'),
        findsNothing,
      );
    });

    testWidgets('shows loading indicator when auth state is loading', (
      tester,
    ) async {
      // Arrange: Set the auth state to loading
      await pumpProfilePage(tester, const AsyncLoading());

      // Assert: Verify the loading indicator is visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
