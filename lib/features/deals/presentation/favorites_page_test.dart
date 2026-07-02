import 'package:dealfinder_app/features/deals/domain/deal.dart';
import 'package:dealfinder_app/features/deals/presentation/deals_notifier.dart';
import 'package:dealfinder_app/features/deals/presentation/favorites_page.dart';
import 'package:dealfinder_app/features/deals/presentation/local_favorites_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('returns an empty list when there are no favorites', () {
      // Arrange: Create a container with mocked providers.
      final container = ProviderContainer(
        overrides: [
          // Mock the deals notifier to return our list of all deals.
          dealsNotifierProvider(
            '',
            DealSort.relevance,
          ).overrideWith((_) => Future.value(DealsState(deals: allDeals))),
          // Mock the favorites notifier to return an empty set.
          localFavoritesNotifierProvider.overrideWith(
            (_) => Future.value(<String>{}),
          ),
        ],
      );

      // Act: Read the value from the provider.
      final favoriteDeals = container.read(favoriteDealsProvider);

      // Assert: The result should be an empty list.
      expect(favoriteDeals, isEmpty);
    });

    test('returns only the deals that are marked as favorite', () {
      // Arrange: Define which deals should be favorites.
      final favoriteIds = {'deal_2', 'deal_4'};

      final container = ProviderContainer(
        overrides: [
          dealsNotifierProvider(
            '',
            DealSort.relevance,
          ).overrideWith((_) => Future.value(DealsState(deals: allDeals))),
          // Mock the favorites notifier to return our set of favorite IDs.
          localFavoritesNotifierProvider.overrideWith(
            (_) => Future.value(favoriteIds),
          ),
        ],
      );

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
