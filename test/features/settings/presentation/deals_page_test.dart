import 'dart:async';
import 'package:dealfinder_pro/features/deals/domain/deal.dart';
import 'package:dealfinder_pro/features/deals/presentation/deals_notifier.dart';
import 'package:dealfinder_pro/features/deals/presentation/deals_page.dart';
import 'package:dealfinder_pro/features/deals/providers/deals_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDealsNotifier extends DealsNotifier {
  final DealsState _dealsState;
  FakeDealsNotifier(this._dealsState);

  @override
  Future<DealsState> build(String query, DealSort sort) async => _dealsState;
}

class FakeDealFeedNotifier extends DealFeedNotifier {
  final List<Deal> _deals;
  FakeDealFeedNotifier(this._deals);

  @override
  Future<List<Deal>> build() async => _deals;
}

void main() {
  group('DealsPage Category Filter', () {
    // Helper to pump the DealsPage with necessary providers
    Future<void> pumpDealsPage(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // We override the dealsProvider for the default parameters to return a stable, non-loading state.
            dealsProvider('', DealSort.relevance).overrideWith(
              () => FakeDealsNotifier(const DealsState(deals: [], hasMore: false)),
            ),
            // Override the feed provider to avoid calling the real repository and App Check
            dealFeedProvider.overrideWith(
              () => FakeDealFeedNotifier([]),
            ),
          ],
          child: const MaterialApp(home: DealsPage()),
        ),
      );
      // pumpAndSettle to wait for the initial frame and any animations.
      await tester.pumpAndSettle();
    }

    testWidgets('initial category is "All"', (tester) async {
      // Arrange
      await pumpDealsPage(tester);

      // Act
      final allChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'All'),
      );

      // Assert
      expect(allChip.selected, isTrue);
    });

    testWidgets('tapping a category chip updates the state', (tester) async {
      // Arrange
      await pumpDealsPage(tester);

      // Find the container to access the provider states
      final element = tester.element(find.byType(DealsPage));
      final container = ProviderScope.containerOf(element);

      // Assert initial state
      expect(container.read(categoryProvider), 'All');

      // Act: Tap the 'Laptops/PC' chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Laptops/PC'));
      await tester.pumpAndSettle();

      // Assert: Check if the provider's state has been updated
      expect(container.read(categoryProvider), 'Laptops/PC');

      // Assert: Check if the UI reflects the new state
      final allChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'All'),
      );
      final laptopChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Laptops/PC'),
      );
      expect(allChip.selected, isFalse);
      expect(laptopChip.selected, isTrue);
    });
  });
}
