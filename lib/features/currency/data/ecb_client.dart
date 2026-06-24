import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../../core/constants.dart';
import '../domain/exchange_rates.dart';

class EcbClient {
  const EcbClient(this._client);

  final http.Client _client;

  Future<ExchangeRates> fetchRates() async {
    try {
      return await _fetchEcb();
    } catch (_) {
      return await _fetchErApi();
    }
  }

  Future<ExchangeRates> _fetchEcb() async {
    final response = await _client
        .get(Uri.parse(ApiUrls.ecbRates))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('ECB returned ${response.statusCode}');
    }

    final doc = XmlDocument.parse(response.body);
    final cubes = doc
        .findAllElements('Cube')
        .where((e) => e.getAttribute('currency') != null);

    final rates = <String, double>{
      CurrencyCode.eur: 1.0,
      for (final cube in cubes)
        cube.getAttribute('currency')!: double.parse(
          cube.getAttribute('rate')!,
        ),
    };

    return ExchangeRates(rates: rates, fetchedAt: DateTime.now());
  }

  Future<ExchangeRates> _fetchErApi() async {
    final response = await _client
        .get(Uri.parse(ApiUrls.ecbRates))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('ER-API returned ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final rawRates = body['rates'] as Map<String, dynamic>;

    final rates = <String, double>{
      CurrencyCode.eur: 1.0,
      for (final entry in rawRates.entries)
        entry.key: (entry.value as num).toDouble(),
    };

    return ExchangeRates(rates: rates, fetchedAt: DateTime.now());
  }
}
