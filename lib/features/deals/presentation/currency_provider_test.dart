import 'package:dealfinder_pro/features/settings/presentation/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formattedPriceProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('formats price with space separated thousands and appends currency', () {
      final result1 = container.read(
        formattedPriceProvider(price: 100.0, currency: 'USD'),
      );
      expect(result1, '100 USD');

      final result2 = container.read(
        formattedPriceProvider(price: 1234567.89, currency: 'SEK'),
      );
      expect(result2, '1 234 568 SEK');
    });
  });
}
