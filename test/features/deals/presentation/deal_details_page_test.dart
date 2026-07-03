import 'dart:async';
import 'package:dealfinder_pro/features/deals/domain/deal.dart';
import 'package:dealfinder_pro/features/deals/presentation/deal_details_page.dart';
import 'package:dealfinder_pro/features/deals/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks.dart';

// Mock for the FavoritesNotifier using a fake class
class MockFavoritesNotifier extends FavoritesNotifier {
  final Set<String> _initialState;
  MockFavoritesNotifier(this._initialState);

  @override
  Future<Set<String>> build() async => _initialState;

  @override
  Future<void> toggleFavorite(String productId) async {
    final current = state.value ?? {};
    if (current.contains(productId)) {
      state = AsyncData(Set<String>.from(current)..remove(productId));
    } else {
      state = AsyncData(Set<String>.from(current)..add(productId));
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
  );

  late MockFavoritesNotifier mockFavoritesNotifier;

  // Helper to pump the DealDetailsPage with necessary providers
  Future<void> pumpDealDetailsPage(
    WidgetTester tester, {
    Set<String> initialFavorites = const {},
  }) async {
    mockFavoritesNotifier = MockFavoritesNotifier(initialFavorites);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith(() => mockFavoritesNotifier),
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
      expect(find.text('100 USD'), findsOneWidget);
      expect(find.text('200 USD'), findsOneWidget); // Original price
      expect(find.textContaining('-50%'), findsOneWidget);
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
      await tester.pump(); // Let the state update and UI rebuild

      // Now it should be a favorite
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
  });
}
