import 'package:dealfinder_pro/features/deals/presentation/user.dart';
import 'package:dealfinder_pro/features/auth/providers/auth_provider.dart';
import 'package:dealfinder_pro/features/auth/presentation/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:dealfinder_pro/features/deals/providers/deals_provider.dart';
import 'mocks.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class FakeSupabaseStreamFilterBuilder extends Stream<List<Map<String, dynamic>>>
    implements SupabaseStreamFilterBuilder {
  @override
  SupabaseStreamFilterBuilder eq(
    String column,
    Object? value,
  ) =>
      this;

  @override
  StreamSubscription<List<Map<String, dynamic>>> listen(
    void Function(List<Map<String, dynamic>> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return const Stream<List<Map<String, dynamic>>>.empty().listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  // A mock user for testing the logged-in state
  const mockUser = User(id: '123', email: 'test@example.com');

  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockSupabaseQueryBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockSupabaseQueryBuilder = MockSupabaseQueryBuilder();

    registerFallbackValue(<String>[]);

    when(() => mockSupabaseClient.from(any()))
        .thenAnswer((_) => mockSupabaseQueryBuilder);
    when(() => mockSupabaseQueryBuilder.stream(primaryKey: any(named: 'primaryKey')))
        .thenAnswer((_) => FakeSupabaseStreamFilterBuilder());
  });

  // Helper to pump the ProfilePage with a given auth state
  Future<void> pumpProfilePage(
    WidgetTester tester,
    AsyncValue<User?> authState,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the authProvider to return a specific state
          authProvider.overrideWith(() => MockAuth(authState)),
          supabaseProvider.overrideWithValue(mockSupabaseClient),
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
      expect(find.widgetWithText(ListTile, 'Sign Out'), findsNothing);
    });

    testWidgets('shows user profile when user is logged in', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Arrange: Set the auth state to logged-in with a mock user
      await pumpProfilePage(tester, const AsyncData(mockUser));

      // Assert: Verify the user's email and the "Sign Out" button are visible
      expect(find.text('test@example.com'), findsOneWidget);

      expect(find.widgetWithText(ListTile, 'Sign Out'), findsOneWidget);

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
