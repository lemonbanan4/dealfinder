import 'dart:async';

import 'package:dealfinder_pro/features/auth/providers/auth_provider.dart';
import 'package:dealfinder_pro/features/deals/presentation/user.dart';
import 'package:dealfinder_pro/features/deals/providers/favorites_provider.dart';
import 'package:dealfinder_pro/providers/repositories.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockUser extends Mock implements User {
  @override
  final String id;
  @override
  final String? email;
  @override
  final bool emailVerified;

  MockUser({this.id = 'test_uid', this.email = 'test@example.com', this.emailVerified = true});

  @override
  String get uid => id;
}



class FakeAuth extends Auth {
  FakeAuth(this._user);
  final User? _user;

  @override
  FutureOr<User?> build() => _user;
}

void main() {
  group('Favorites Provider', () {
    late ProviderContainer container;
    late MockUser mockUser;
    late FakeFirebaseFirestore fakeFirestore;
    late MockSharedPreferences mockSharedPreferences;

    const favoritesKey = 'local_favorite_deals';

    setUp(() {
      mockUser = MockUser();
      fakeFirestore = FakeFirebaseFirestore();
      mockSharedPreferences = MockSharedPreferences();
    });

    tearDown(() {
      try {
        container.dispose();
      } catch (_) {}
    });

    Future<void> awaitInitialization(ProviderContainer container) async {
      await container.read(authProvider.future);
      await container.read(favoritesProvider.future);
    }

    test('initial state is empty and loads from SharedPreferences', () async {
      final mockPrefs = MockSharedPreferences();
      when(
        () => mockPrefs.getStringList(favoritesKey),
      ).thenReturn(['deal1', 'deal2']);

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(AsyncValue.data(mockPrefs)),
          firestoreProvider.overrideWithValue(fakeFirestore),
          authProvider.overrideWith(() => FakeAuth(null)),
        ],
      );

      await awaitInitialization(container);

      expect(container.read(favoritesProvider).requireValue, {'deal1', 'deal2'});
    });

    test('toggleFavorite adds a new favorite', () async {
      final mockPrefs = MockSharedPreferences();
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn([]);
      when(
        () => mockPrefs.setStringList(favoritesKey, any()),
      ).thenAnswer((_) async => true);

      container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(mockUser)),
          firestoreProvider.overrideWithValue(fakeFirestore),
          sharedPreferencesProvider.overrideWithValue(AsyncValue.data(mockPrefs)),
        ],
      );

      await awaitInitialization(container);

      final notifier = container.read(favoritesProvider.notifier);
      await notifier.toggleFavorite('deal1');

      expect(container.read(favoritesProvider).requireValue, {'deal1'});

      final doc = await fakeFirestore
          .collection('users')
          .doc(mockUser.uid)
          .get();
      expect(doc.data()?['favorites'], ['deal1']);
    });

    test('toggleFavorite removes an existing favorite', () async {
      final mockPrefs = MockSharedPreferences();
      when(
        () => mockPrefs.getStringList(favoritesKey),
      ).thenReturn(['deal1', 'deal2']);
      when(
        () => mockPrefs.setStringList(favoritesKey, any()),
      ).thenAnswer((_) async => true);

      container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(mockUser)),
          firestoreProvider.overrideWithValue(fakeFirestore),
          sharedPreferencesProvider.overrideWithValue(AsyncValue.data(mockPrefs)),
        ],
      );

      await fakeFirestore.collection('users').doc(mockUser.uid).set({
        'favorites': ['deal1', 'deal2'],
      });

      await awaitInitialization(container);

      final notifier = container.read(favoritesProvider.notifier);
      await notifier.toggleFavorite('deal1');

      expect(container.read(favoritesProvider).requireValue, {'deal2'});

      final doc = await fakeFirestore
          .collection('users')
          .doc(mockUser.uid)
          .get();
      expect(doc.data()?['favorites'], ['deal2']);
    });

    test('toggleFavorite throws exception if email is not verified', () async {
      final unverifiedUser = MockUser(emailVerified: false);
      final mockPrefs = MockSharedPreferences();
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn([]);

      container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(unverifiedUser)),
          firestoreProvider.overrideWithValue(fakeFirestore),
          sharedPreferencesProvider.overrideWithValue(AsyncValue.data(mockPrefs)),
        ],
      );

      await awaitInitialization(container);

      final notifier = container.read(favoritesProvider.notifier);

      expect(
        notifier.toggleFavorite('deal1'),
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
          sharedPreferencesProvider.overrideWithValue(AsyncValue.data(mockPrefs)),
          firestoreProvider.overrideWithValue(fakeFirestore),
          authProvider.overrideWith(() => FakeAuth(null)),
        ],
      );

      await awaitInitialization(container);

      final notifier = container.read(favoritesProvider.notifier);

      expect(container.read(favoritesProvider).requireValue, {'deal1', 'deal2'});

      await notifier.clear();

      expect(container.read(favoritesProvider).requireValue, isEmpty);
    });

    test(
      'clear removes all favorites from SharedPreferences and Firestore',
      () async {
        final mockPrefs = MockSharedPreferences();
        when(
          () => mockPrefs.getStringList(favoritesKey),
        ).thenReturn(['deal1', 'deal2']);
        when(
          () => mockPrefs.remove(favoritesKey),
        ).thenAnswer((_) async => true);

        container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(() => FakeAuth(mockUser)),
            firestoreProvider.overrideWithValue(fakeFirestore),
            sharedPreferencesProvider.overrideWithValue(AsyncValue.data(mockPrefs)),
          ],
        );

        await fakeFirestore.collection('users').doc(mockUser.uid).set({
          'favorites': ['deal1', 'deal2'],
        });

        await awaitInitialization(container);

        final notifier = container.read(favoritesProvider.notifier);
        await notifier.clear();

        expect(container.read(favoritesProvider).requireValue, isEmpty);
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
