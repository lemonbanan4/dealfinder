import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealfinder_app/features/auth/providers/auth_provider.dart';
import 'package:dealfinder_app/features/deals/domain/deal.dart';
import 'package:dealfinder_app/features/deals/presentation/feed_page.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockUser extends Mock implements User {
  @override
  final String uid;
  @override
  final bool emailVerified;

  MockUser({this.uid = 'test_uid', this.emailVerified = true});
}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('Favorites Provider', () {
    late ProviderContainer container;
    late MockUser mockUser;
    late FakeFirebaseFirestore fakeFirestore;
    late MockSharedPreferences mockSharedPreferences;

    const favoritesKey = 'favorite_products_pref';

    final deal1 = Deal(
      id: 'deal1',
      title: 'Deal 1',
      url: 'url1',
      source: 'source1',
      currentPrice: 100,
      currency: 'USD',
    );

    setUp(() {
      // Initialize mocks for each test
      mockUser = MockUser();
      fakeFirestore = FakeFirebaseFirestore();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty and loads from SharedPreferences', () async {
      // 1. Setup
      final mockPrefs = MockSharedPreferences();
      when(
        () => mockPrefs.getStringList(favoritesKey),
      ).thenReturn(['deal1', 'deal2']);

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          // Provide a default for authProvider to avoid errors
          authProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );

      // 2. Act
      // The first read will trigger the build and load from prefs
      await container.read(favoritesProvider.future);
      final favorites = container.read(favoritesProvider);

      // 3. Assert
      expect(favorites, {'deal1', 'deal2'});
    });

    test('toggleFavorite adds a new favorite', () async {
      // 1. Setup
      final mockPrefs = MockSharedPreferences();
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn([]);
      when(
        () => mockPrefs.setStringList(favoritesKey, any()),
      ).thenAnswer((_) async => true);

      container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => Stream.value(mockUser)),
          firestoreProvider.overrideWithValue(fakeFirestore),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );

      // Replace the global instance for this test
      // final originalFirestore = FirebaseFirestore.instance;
      // FirebaseFirestore.instance = fakeFirestore;

      final notifier = container.read(favoritesProvider.notifier);
      await notifier.build(); // Manually build to load initial state

      // 2. Act
      await notifier.toggleFavorite('deal1');

      // 3. Assert
      expect(container.read(favoritesProvider), {'deal1'});

      // Verify it was written to Firestore
      final doc = await fakeFirestore
          .collection('users')
          .doc(mockUser.uid)
          .get();
      expect(doc.data()?['favorites'], ['deal1']);

      // Restore original instance
      // FirebaseFirestore.instance = originalFirestore;
    });

    test('toggleFavorite removes an existing favorite', () async {
      // 1. Setup
      final mockPrefs = MockSharedPreferences();
      when(
        () => mockPrefs.getStringList(favoritesKey),
      ).thenReturn(['deal1', 'deal2']);
      when(
        () => mockPrefs.setStringList(favoritesKey, any()),
      ).thenAnswer((_) async => true);

      container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => Stream.value(mockUser)),
          firestoreProvider.overrideWithValue(fakeFirestore),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );

      await fakeFirestore.collection('users').doc(mockUser.uid).set({
        'favorites': ['deal1', 'deal2'],
      });

      final notifier = container.read(favoritesProvider.notifier);
      await notifier.build(); // Load initial state

      // 2. Act
      await notifier.toggleFavorite('deal1');

      // 3. Assert
      expect(container.read(favoritesProvider), {'deal2'});

      final doc = await fakeFirestore
          .collection('users')
          .doc(mockUser.uid)
          .get();
      expect(doc.data()?['favorites'], ['deal2']);

      // FirebaseFirestore.instance = originalFirestore;
    });

    test('toggleFavorite throws exception if email is not verified', () async {
      // 1. Setup
      final unverifiedUser = MockUser(emailVerified: false);
      final mockPrefs = MockSharedPreferences();
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn([]);

      container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => Stream.value(unverifiedUser)),
          firestoreProvider.overrideWithValue(fakeFirestore),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );

      final notifier = container.read(favoritesProvider.notifier);
      await notifier.build();

      // 2. Act & 3. Assert
      expect(
        () => notifier.toggleFavorite('deal1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Email not verified',
          ),
        ),
      );
    });

    test('clear removes all favorites', () async {
      final mockPrefs = MockSharedPreferences();
      when(
        () => mockPrefs.getStringList(favoritesKey),
      ).thenReturn(['deal1', 'deal2']);
      when(() => mockPrefs.remove(favoritesKey)).thenAnswer((_) async => true);

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          authProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );

      final notifier = container.read(favoritesProvider.notifier);
      await notifier.build();

      expect(container.read(favoritesProvider), {'deal1', 'deal2'});

      await notifier.clear();

      expect(container.read(favoritesProvider), isEmpty);
    });

    test(
      'clear removes all favorites from SharedPreferences and Firestore',
      () async {
        // 1. Setup
        final mockPrefs = MockSharedPreferences();
        when(
          () => mockPrefs.getStringList(favoritesKey),
        ).thenReturn(['deal1', 'deal2']);
        when(
          () => mockPrefs.remove(favoritesKey),
        ).thenAnswer((_) async => true);

        container = ProviderContainer(
          overrides: [
            authProvider.overrideWith((ref) => Stream.value(mockUser)),
            firestoreProvider.overrideWithValue(fakeFirestore),
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
        );

        // Pre-populate firestore and state
        await fakeFirestore.collection('users').doc(mockUser.uid).set({
          'favorites': ['deal1', 'deal2'],
        });
        final notifier = container.read(favoritesProvider.notifier);
        await container.read(
          favoritesProvider.future,
        ); // Wait for initial build

        // 2. Act
        await notifier.clear();

        // 3. Assert
        expect(container.read(favoritesProvider).asData?.value, isEmpty);
        verify(() => mockPrefs.remove(favoritesKey)).called(1);
        final doc = await fakeFirestore
            .collection('users')
            .doc(mockUser.uid)
            .get();
        expect(doc.data()?['favorites'], []);
      },
    );
  });
}
