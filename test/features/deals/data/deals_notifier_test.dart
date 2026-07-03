import 'package:dealfinder_pro/features/deals/data/deals_repository.dart';
import 'package:dealfinder_pro/features/deals/domain/deal.dart';
import 'package:dealfinder_pro/features/deals/presentation/deals_page.dart';
import 'package:dealfinder_pro/features/deals/presentation/deals_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Create a Mock for the repository
class MockDealsRepository extends Mock implements DealsRepository {}

void main() {
  // Helper to create a list of mock deals
  List<Deal> createMockDeals(int count, {int startingId = 1}) {
    return List.generate(
      count,
      (i) => Deal(
        id: 'deal_${startingId + i}',
        title: 'Deal ${startingId + i}',
        source: 'Test',
        url: 'http://test.com/deal/${startingId + i}',
        currentPrice: 100.0,
        currency: 'USD',
      ),
    );
  }

  group('DealsNotifier', () {
    late MockDealsRepository mockDealsRepository;
    late ProviderContainer container;
    late DealsNotifier notifier;

    setUp(() {
      mockDealsRepository = MockDealsRepository();
      registerFallbackValue(1);

      container = ProviderContainer(
        overrides: [
          dealsRepositoryProvider.overrideWithValue(mockDealsRepository),
        ],
      );
    });

    tearDown(() {
      try {
        container.dispose();
      } catch (_) {}
    });

    final provider = dealsProvider('', DealSort.relevance);

    void initNotifier() {
      container.listen(provider, (previous, next) {});
      notifier = container.read(provider.notifier);
    }

    test('Initial state is loading, then fetches first page', () async {
      // Arrange
      final mockDeals = createMockDeals(20);
      when(
        () => mockDealsRepository.fetchDeals(
          page: 1,
          query: any(named: 'query'),
          sort: any(named: 'sort'),
          category: any(named: 'category'),
        ),
      ).thenAnswer((_) async => mockDeals);

      // Act
      initNotifier();
      await pumpEventQueue();

      // Assert
      final state = container.read(provider);
      expect(state.value!.deals.length, 20);
      expect(state.isLoading, isFalse);
      expect(state.value!.hasMore, isTrue);
    });

    test('fetchNextPage appends new deals to the state', () async {
      // Arrange: Set up initial state
      final initialDeals = createMockDeals(20, startingId: 1);
      when(
        () => mockDealsRepository.fetchDeals(
          page: 1,
          query: any(named: 'query'),
          sort: any(named: 'sort'),
          category: any(named: 'category'),
        ),
      ).thenAnswer((_) async => initialDeals);
      
      initNotifier();
      await pumpEventQueue(); // Wait for initial fetch

      // Arrange: Set up for the next page fetch
      final nextDeals = createMockDeals(10, startingId: 21);
      when(
        () => mockDealsRepository.fetchDeals(
          page: 2,
          query: any(named: 'query'),
          sort: any(named: 'sort'),
          category: any(named: 'category'),
        ),
      ).thenAnswer((_) async => nextDeals);

      // Act
      await notifier.fetchNextPage();

      // Assert
      final state = container.read(provider);
      expect(state.value!.deals.length, 30); // 20 initial + 10 new
      expect(state.value!.hasMore, isFalse); // Fetched less than a full page
      expect(state.value!.deals.last.title, 'Deal 30');
    });

    test('refresh clears existing deals and fetches page 1', () async {
      // Arrange: Set up initial state with some deals
      final initialDeals = createMockDeals(20, startingId: 1);
      when(
        () => mockDealsRepository.fetchDeals(
          page: 1,
          query: any(named: 'query'),
          sort: any(named: 'sort'),
          category: any(named: 'category'),
        ),
      ).thenAnswer((_) async => initialDeals);
      
      initNotifier();
      await pumpEventQueue(); // Wait for initial fetch
      expect(container.read(provider).value!.deals.length, 20);

      // Arrange: Set up for the refresh call
      final refreshedDeals = createMockDeals(5, startingId: 101);
      when(
        () => mockDealsRepository.fetchDeals(
          page: 1,
          query: any(named: 'query'),
          sort: any(named: 'sort'),
          category: any(named: 'category'),
        ),
      ).thenAnswer((_) async => refreshedDeals);

      // Act
      // Refresh is triggered by invalidating/refreshing the provider
      final future = container.refresh(provider.future);
      await future;

      // Assert
      final state = container.read(provider);
      expect(state.value!.deals.length, 5);
      expect(state.value!.deals.first.title, 'Deal 101');
      expect(state.isLoading, isFalse);
    });
  });
}
