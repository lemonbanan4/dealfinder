import 'dart:convert';

import 'package:dealfinder_pro/features/deals/data/deals_repository.dart';
import 'package:dealfinder_pro/features/deals/domain/deal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

// 1. Create a Mock class for the dependency (http.Client)
class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  late DealsRepository dealsRepository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    // 2. Inject the mock dependency into the repository
    dealsRepository = DealsRepository(client: mockHttpClient);
  });

  group('DealsRepository', () {
    const page = 1;

    // A sample successful JSON response matching the scraper schema
    final mockApiResponse = jsonEncode([
      {
        'product_id': 'deal_1',
        'title': 'accusamus beatae ad facilis cum similique qui sunt',
        'brand': 'Test Brand',
        'tracking_url': 'https://via.placeholder.com/600/92c952',
        'image_url': 'https://via.placeholder.com/150/92c952',
        'price': 99.99,
      },
    ]);

    test('fetchDeals returns a list of deals on success (200)', () async {
      // 3. Arrange: Setup the mock to return a successful response
      when(
        () => mockHttpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(mockApiResponse, 200));

      // 4. Act: Call the method we are testing
      final result = await dealsRepository.fetchDeals(page: page);

      // 5. Assert: Check if the result is what we expect
      expect(result, isA<List<Deal>>());
      expect(result.length, 1);
      expect(
        result.first.title,
        'accusamus beatae ad facilis cum similique qui sunt',
      );
      expect(result.first.currentPrice, 99.99);
      expect(result.first.source, 'Test Brand');
    });

    test('fetchDeals throws an exception on failure (non-200)', () async {
      // Arrange: Setup the mock to return an error response
      when(
        () => mockHttpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert: Check that the method throws the expected exception
      expect(
        () => dealsRepository.fetchDeals(page: page),
        throwsA(isA<Exception>()),
      );
    });
  });
}

/// Helper to register a fallback for any() from mocktail
void registerFallbackValues() {
  registerFallbackValue(Uri.parse('http://fake.com'));
}

void test_main() {
  registerFallbackValues();
  main();
}
