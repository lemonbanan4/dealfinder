import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';

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
      // Routed through the backend (rather than calling exchangerate-api.com
      // directly) so its API key lives only in that server's environment —
      // a Flutter web build ships every client-side string in plain text,
      // so a key embedded here would be trivially readable by anyone via
      // devtools on a public site.
      final response = await apiGet('/api/exchange-rates');
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
      // If fetching fails, return the old (stale) rates if they exist.
      return previousState;
    } catch (e) {
      // On error (including a timeout, now that apiGet always applies one),
      // return old data to prevent the app from breaking.
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
