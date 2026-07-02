import 'package:dealfinder_pro/features/deals/domain/deal.dart';
import 'package:dealfinder_pro/features/deals/presentation/deal_details_page.dart';
import 'package:dealfinder_pro/features/deals/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

// Mock for the FavoritesNotifier
class MockFavoritesNotifier extends StateNotifier<AsyncValue<Set<String>>>
    with Mock
    implements FavoritesNotifier {
  MockFavoritesNotifier(super.state);

  @override
  Future<void> toggleFavorite(String dealId) async {
    final currentState = state.value ?? {};
    if (currentState.contains(dealId)) {
      state = AsyncData(currentState..remove(dealId));
    } else {
      state = AsyncData(currentState..add(dealId));
    }
  }
}

void main() {
  // A mock deal to use in tests
  const mockDeal = Deal(
    id: 'deal_1',
    title: 'Awesome Gadget',
    source: 'Gadget Store',
    url: 'http://example.com/deal/1',
    imageUrl: 'http://example.com/image.png',
    currentPrice: 99.99,
    originalPrice: 199.99,
    currency: 'USD',
    discountPercent: 50,
  );

  late MockFavoritesNotifier mockFavoritesNotifier;

  // Helper to pump the DealDetailsPage with necessary providers
  Future<void> pumpDealDetailsPage(
    WidgetTester tester, {
    Set<String> initialFavorites = const {},
  }) async {
    mockFavoritesNotifier = MockFavoritesNotifier(AsyncData(initialFavorites));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((ref) => mockFavoritesNotifier),
        ],
        child: const MaterialApp(home: DealDetailsPage(deal: mockDeal)),
      ),
    );
  }

  group('DealDetailsPage', () {
    testWidgets('displays deal information correctly', (tester) async {
      await pumpDealDetailsPage(tester);

      // Verify all the deal details are on screen
      expect(find.text('Awesome Gadget'), findsOneWidget);
      expect(find.text('Gadget Store'), findsOneWidget); // In SliverAppBar
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('\$199.99'), findsOneWidget); // Original price
      expect(find.textContaining('50% OFF'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'View on Retailer Site'),
        findsOneWidget,
      );
    });

    testWidgets('toggles favorite status when favorite icon is tapped', (
      tester,
    ) async {
      await pumpDealDetailsPage(tester);

      // Initially, it's not a favorite
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      // Tap the favorite button
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle(); // Let the state update and UI rebuild

      // Now it should be a favorite
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
  });
}
