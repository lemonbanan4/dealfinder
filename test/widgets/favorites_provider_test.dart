import 'dart:async';
import 'package:dealfinder_pro/features/auth/providers/auth_provider.dart';
import 'package:dealfinder_pro/features/deals/data/favorites_repository.dart';
import 'package:dealfinder_pro/features/deals/presentation/user.dart';
import 'package:dealfinder_pro/features/deals/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

// Mocks for dependencies
class MockFavoritesRepository extends Mock implements FavoritesRepository {}

// Fake Auth notifier to override the user auth state
class FakeAuth extends Auth {
  final User? _user;
  FakeAuth(this._user);

  @override
  FutureOr<User?> build() => _user;
}

void main() {
  late MockFavoritesRepository mockFavoritesRepository;
  late MockUser mockUser;

  setUp(() {
    mockFavoritesRepository = MockFavoritesRepository();
    mockUser = MockUser();
    // Stub the mock user's properties
    when(() => mockUser.id).thenReturn('test-user-id');
    when(() => mockUser.email).thenReturn('test@example.com');
  });

  // A helper to create a ProviderContainer with overrides
  ProviderContainer createContainer({User? authedUser}) {
    return ProviderContainer(
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(mockFavoritesRepository),
        // Override the authProvider to return the fake user auth state
        authProvider.overrideWith(() => FakeAuth(authedUser)),
      ],
    );
  }

  group('FavoritesNotifier', () {
    test('Initial state is empty set when user is not logged in', () async {
      // Arrange
      when(
        () => mockFavoritesRepository.getFavorites(null),
      ).thenAnswer((_) async => <String>{});
      final container = createContainer(authedUser: null);

      // Act
      final listener = container.listen(
        favoritesProvider,
        (previous, next) {},
      );

      // Assert
      expect(listener.read(), const AsyncValue<Set<String>>.loading());
      await container.read(favoritesProvider.future);
      expect(listener.read().value, equals(<String>{}));
      verify(() => mockFavoritesRepository.getFavorites(null)).called(1);
    });

    test(
      'Initial state loads favorites from repository when user is logged in',
      () async {
        // Arrange
        final initialFavs = {'deal_1', 'deal_2'};
        when(
          () => mockFavoritesRepository.getFavorites(mockUser),
        ).thenAnswer((_) async => initialFavs);
        final container = createContainer(authedUser: mockUser);

        // Act
        final listener = container.listen(
          favoritesProvider,
          (previous, next) {},
        );
        await container.read(authProvider.future);
        await container.read(favoritesProvider.future);

        // Assert
        expect(listener.read().value, equals(initialFavs));
        verify(() => mockFavoritesRepository.getFavorites(mockUser)).called(1);
      },
    );

    test('toggleFavorite adds a new favorite optimistically', () async {
      // Arrange
      const dealId = 'new_deal';
      when(
        () => mockFavoritesRepository.getFavorites(mockUser),
      ).thenAnswer((_) async => <String>{});
      when(
        () => mockFavoritesRepository.toggleFavorite(dealId, mockUser),
      ).thenAnswer((_) async {});
      final container = createContainer(authedUser: mockUser);
      await container.read(authProvider.future);
      await container.read(favoritesProvider.future);

      // Act
      final future = container
          .read(favoritesProvider.notifier)
          .toggleFavorite(dealId);

      // Assert
      expect(container.read(favoritesProvider).value, equals({dealId}));

      await future;

      verify(
        () => mockFavoritesRepository.toggleFavorite(dealId, mockUser),
      ).called(1);
    });

    test(
      'toggleFavorite removes an existing favorite optimistically',
      () async {
        // Arrange
        const dealId = 'existing_deal';
        when(
          () => mockFavoritesRepository.getFavorites(mockUser),
        ).thenAnswer((_) async => {dealId});
        when(
          () => mockFavoritesRepository.toggleFavorite(dealId, mockUser),
        ).thenAnswer((_) async {});
        final container = createContainer(authedUser: mockUser);
        await container.read(authProvider.future);
        await container.read(favoritesProvider.future);

        // Act
        final future = container
            .read(favoritesProvider.notifier)
            .toggleFavorite(dealId);

        // Assert
        expect(container.read(favoritesProvider).value, equals(<String>{}));

        await future;

        verify(
          () => mockFavoritesRepository.toggleFavorite(dealId, mockUser),
        ).called(1);
      },
    );

    test(
      'toggleFavorite reverts state and rethrows on repository failure',
      () async {
        // Arrange
        const dealId = 'deal_1';
        final exception = Exception('API Error');
        when(
          () => mockFavoritesRepository.getFavorites(mockUser),
        ).thenAnswer((_) async => <String>{});
        when(
          () => mockFavoritesRepository.toggleFavorite(dealId, mockUser),
        ).thenAnswer((_) => Future.error(exception));
        final container = createContainer(authedUser: mockUser);
        await container.read(authProvider.future);
        await container.read(favoritesProvider.future);

        // Act
        final future = container
            .read(favoritesProvider.notifier)
            .toggleFavorite(dealId);

        // Assert
        // The state is optimistically updated first
        expect(container.read(favoritesProvider).value, equals({dealId}));

        // Then it should fail and revert
        await expectLater(future, throwsA(isA<Exception>()));

        // The state should be reverted to its original empty set
        expect(container.read(favoritesProvider).value, equals(<String>{}));

        verify(
          () => mockFavoritesRepository.toggleFavorite(dealId, mockUser),
        ).called(1);
      },
    );
  });
}
