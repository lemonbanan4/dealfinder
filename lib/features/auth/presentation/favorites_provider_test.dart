import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../../deals/domain/deal.dart';
import '../../deals/presentation/feed_page.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
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

class FakeAuthProvider extends AuthProvider {
  FakeAuthProvider(this._userStream);
  final Stream<User?> _userStream;

  @override
  Stream<User?> build() => _userStream;
}

void main() {
  group('Favorites Provider', () {
    late ProviderContainer container;
    late MockUser mockUser;
    late FakeFirebaseFirestore fakeFirestore;
    late MockSharedPreferences mockSharedPreferences;

    const favoritesKey = 'favorite_products_pref';

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
          authProvider.overrideWith(() => FakeAuthProvider(Stream<User?>.value(null)) as AuthProvider),
        ],
      );

      await awaitInitialization(container);
      final favorites = container.read(favoritesProvider).requireValue;

      expect(favorites, {'deal1', 'deal2'});
    });

    test('toggleFavorite adds a new favorite', () async {
      final mockPrefs = MockSharedPreferences();
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn([]);
      when(
        () => mockPrefs.setStringList(favoritesKey, any()),
      ).thenAnswer((_) async => true);

      container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuthProvider(Stream<User?>.value(mockUser)) as AuthProvider),
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
          authProvider.overrideWith(() => FakeAuthProvider(Stream<User?>.value(mockUser)) as AuthProvider),
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
          authProvider.overrideWith(() => FakeAuthProvider(Stream<User?>.value(unverifiedUser)) as AuthProvider),
          firestoreProvider.overrideWithValue(fakeFirestore),
          sharedPreferencesProvider.overrideWithValue(AsyncValue.data(mockPrefs)),
        ],
      );

      await awaitInitialization(container);

      final notifier = container.read(favoritesProvider.notifier);

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
          sharedPreferencesProvider.overrideWithValue(AsyncValue.data(mockPrefs)),
          firestoreProvider.overrideWithValue(fakeFirestore),
          authProvider.overrideWith(() => FakeAuthProvider(Stream<User?>.value(null)) as AuthProvider),
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
            authProvider.overrideWith(() => FakeAuthProvider(Stream<User?>.value(mockUser)) as AuthProvider),
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
