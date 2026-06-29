import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'currency_provider.g.dart';

/// A simple model to hold the fetched exchange rate data.
class ExchangeRates {
  ExchangeRates({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastUpdated;
}

@Riverpod(keepAlive: true)
class CurrencyConverter extends _$CurrencyConverter {
  // IMPORTANT: Replace with your own API key from a provider like exchangerate-api.com
  // It's best practice to load this from environment variables rather than hardcoding.
  final _apiKey = 'c3593d75019cfbd8df32f9ef';

  // We'll fetch all rates against SEK as the base currency.
  final _baseCurrency = 'SEK';

  @override
  Future<ExchangeRates?> build() async {
    // Fetch rates when the provider is first read.
    return _fetchRates();
  }

  /// Fetches the latest exchange rates from the API.
  /// Includes simple in-memory caching to avoid excessive API calls.
  Future<ExchangeRates?> _fetchRates() async {
    // Use cached data if it's less than 12 hours old.
    final previousState = state.asData?.value;
    if (previousState != null &&
        DateTime.now().difference(previousState.lastUpdated).inHours < 12) {
      return previousState;
    }

    try {
      final url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/$_apiKey/latest/$_baseCurrency',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          final ratesData = data['conversion_rates'] as Map<String, dynamic>;
          final ratesMap = ratesData.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          );

          final newRates = ExchangeRates(
            baseCurrency: data['base_code'],
            rates: ratesMap,
            lastUpdated: DateTime.now(),
          );
          return newRates;
        }
      }
      // If fetching fails, return the old (stale) rates if they exist.
      return previousState;
    } catch (e) {
      // On error, return old data to prevent the app from breaking.
      return previousState;
    }
  }

  /// Converts a price from its original currency to the target currency.
  ///
  /// Returns the original price if conversion is not possible.
  double convert(double price, String from, String to) {
    final ratesData = state.asData?.value;
    if (ratesData == null) return price; // Not ready yet

    final rates = ratesData.rates;
    if (from == to) return price;

    // Our base currency is SEK.
    // First, convert 'from' currency to SEK.
    final fromRate = rates[from];
    if (fromRate == null) return price; // 'from' currency not found
    final priceInBase = price / fromRate;

    // Then, convert from SEK to the 'to' currency.
    final toRate = rates[to];
    if (toRate == null) return price; // 'to' currency not found

    return priceInBase * toRate;
  }

  /// Manually triggers a refresh of the exchange rates.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRates());
  }
}

/// A convenience provider that returns a formatted price string.
@riverpod
String formattedPrice(
  Ref ref, {
  required double price,
  required String currency,
}) {
  final rounded = price.round();
  final s = rounded.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${buf.toString()} $currency';
}
