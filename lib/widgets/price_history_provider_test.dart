import 'package:dealfinder_app/features/deals/providers/deals_provider.dart';
import 'package:dealfinder_app/widgets/deal_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Create Mocks for Supabase dependencies
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestClient extends Mock implements PostgrestClient {}

class MockPostgrestQueryBuilder extends Mock
    implements PostgrestQueryBuilder<Map<String, dynamic>> {}

void main() {
  group('priceHistoryProvider', () {
    late ProviderContainer container;
    late MockSupabaseClient mockSupabaseClient;
    late MockPostgrestClient mockPostgrestClient;
    late MockPostgrestQueryBuilder mockQueryBuilder;

    setUp(() {
      // 2. Initialize mocks before each test
      mockSupabaseClient = MockSupabaseClient();
      mockPostgrestClient = MockPostgrestClient();
      mockQueryBuilder = MockPostgrestQueryBuilder();

      // 3. Stub the Supabase call chain
      when(
        () => mockSupabaseClient.from(any()),
      ).thenReturn(mockPostgrestClient);
      when(
        () => mockPostgrestClient.select(any()),
      ).thenReturn(mockQueryBuilder);
      when(
        () => mockQueryBuilder.eq(any(), any()),
      ).thenReturn(mockQueryBuilder);
      when(
        () => mockQueryBuilder.order(any(), ascending: any(named: 'ascending')),
      ).thenReturn(mockQueryBuilder);

      // 4. Create a ProviderContainer and override the supabaseProvider
      container = ProviderContainer(
        overrides: [supabaseProvider.overrideWithValue(mockSupabaseClient)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns a list of FlSpot on success', () async {
      // Arrange: Define the mock response from Supabase
      final mockResponse = [
        {'price': 100.0, 'recorded_at': '2023-01-01T12:00:00Z'},
        {'price': 120.0, 'recorded_at': '2023-01-02T12:00:00Z'},
      ];
      when(
        () => mockQueryBuilder.then(any()),
      ).thenAnswer((_) async => mockResponse);

      // Act: Read the provider. The `future` will complete when the provider is done.
      final result = await container.read(
        priceHistoryProvider('product-1').future,
      );

      // Assert: Check if the result is what we expect
      expect(result, isA<List<FlSpot>>());
      expect(result.length, 2);
      expect(result.first.y, 100.0);
      expect(result.last.y, 120.0);
    });

    test('throws an exception on Supabase error', () async {
      // Arrange: Make the Supabase call throw an error
      final exception = Exception('Network error');
      when(() => mockQueryBuilder.then(any())).thenThrow(exception);

      // Act & Assert: Expect the provider's future to result in an error
      expect(
        container.read(priceHistoryProvider('product-1').future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
