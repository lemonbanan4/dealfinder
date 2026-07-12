import 'package:dealfinder_pro/features/deals/domain/deal.dart';
import 'package:dealfinder_pro/features/deals/presentation/favorites_page.dart';
import 'package:dealfinder_pro/features/deals/providers/deals_provider.dart';
import 'package:dealfinder_pro/features/deals/providers/favorites_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFavoritesNotifier extends FavoritesNotifier {
  final Set<String> _favs;
  FakeFavoritesNotifier(this._favs);

  @override
  Future<Set<String>> build() async => _favs;
}

class FakeDealFeedNotifier extends DealFeedNotifier {
  final List<Deal> _deals;
  FakeDealFeedNotifier(this._deals);

  @override
  Future<List<Deal>> build() async => _deals;
}

void main() {
  // Helper to create a list of mock deals for testing.
  List<Deal> createMockDeals(List<int> ids) {
    return ids.map((id) {
      return Deal(
        id: 'deal_$id',
        title: 'Deal $id',
        source: 'Test',
        url: 'http://test.com/deal/$id',
        currentPrice: 100.0,
        currency: 'USD',
      );
    }).toList();
  }

  group('favoriteDealsProvider', () {
    // Create some mock deals to use in the tests.
    final allDeals = createMockDeals([1, 2, 3, 4, 5]);

    test('returns an empty list when there are no favorites', () async {
      // Arrange: Create a container with mocked providers.
      final container = ProviderContainer(
        overrides: [
          // Mock the deal feed to return our list of all deals.
          dealFeedProvider.overrideWith(() => FakeDealFeedNotifier(allDeals)),
          // Mock the favorites notifier to return an empty set.
          favoritesProvider.overrideWith(
            () => FakeFavoritesNotifier(<String>{}),
          ),
        ],
      );

      await container.read(dealFeedProvider.future);
      await container.read(favoritesProvider.future);

      // Act: Read the value from the provider.
      final favoriteDeals = container.read(favoriteDealsProvider);

      // Assert: The result should be an empty list.
      expect(favoriteDeals, isEmpty);
    });

    test('returns only the deals that are marked as favorite', () async {
      // Arrange: Define which deals should be favorites.
      final favoriteIds = {'deal_2', 'deal_4'};

      final container = ProviderContainer(
        overrides: [
          dealFeedProvider.overrideWith(() => FakeDealFeedNotifier(allDeals)),
          // Mock the favorites notifier to return our set of favorite IDs.
          favoritesProvider.overrideWith(
            () => FakeFavoritesNotifier(favoriteIds),
          ),
        ],
      );

      await container.read(dealFeedProvider.future);
      await container.read(favoritesProvider.future);

      // Act
      final favoriteDeals = container.read(favoriteDealsProvider);

      // Assert
      // Check that the list contains exactly 2 items.
      expect(favoriteDeals.length, 2);
      // Check that the IDs of the returned deals match our favorite IDs.
      expect(favoriteDeals.map((d) => d.id).toSet(), equals(favoriteIds));
      // Check a specific deal to be sure.
      expect(favoriteDeals.first.title, 'Deal 2');
      expect(favoriteDeals.last.title, 'Deal 4');
    });
  });
}
