import 'dart:convert';

import 'package:dealfinder_pro/features/deals/data/deals_repository.dart';
import 'package:dealfinder_pro/features/deals/domain/deal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

// 1. Create a Mock class for the dependency (http.Client)
class MockHttpClient extends Mock implements http.Client {}

void main() {
  late DealsRepository dealsRepository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    // 2. Inject the mock dependency into the repository
    dealsRepository = DealsRepository(client: mockHttpClient);
  });

  group('DealsRepository', () {
    const page = 1;
    final uri = Uri.parse(
      'https://jsonplaceholder.typicode.com/photos?_page=$page&_limit=20',
    );

    // A sample successful JSON response from the API
    final mockApiResponse = jsonEncode([
      {
        'albumId': 1,
        'id': 1,
        'title': 'accusamus beatae ad facilis cum similique qui sunt',
        'url': 'https://via.placeholder.com/600/92c952',
        'thumbnailUrl': 'https://via.placeholder.com/150/92c952',
      },
    ]);

    test('fetchDeals returns a list of deals on success (200)', () async {
      // 3. Arrange: Setup the mock to return a successful response
      when(
        () => mockHttpClient.get(uri),
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
    });

    test('fetchDeals throws an exception on failure (non-200)', () async {
      // Arrange: Setup the mock to return an error response
      when(
        () => mockHttpClient.get(uri),
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
