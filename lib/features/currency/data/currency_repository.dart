import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants.dart';
import '../domain/exchange_rates.dart';

class CurrencyRepository {
  static const _key = 'rates';

  Box<String> get _box => Hive.box<String>(HiveBoxes.currencyRates);

  ExchangeRates? getCached() {
    final raw = _box.get(_key);
    if (raw == null) return null;
    return ExchangeRates.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(ExchangeRates rates) =>
      _box.put(_key, jsonEncode(rates.toJson()));

  bool isFresh(ExchangeRates rates) =>
      DateTime.now().difference(rates.fetchedAt) < ratesCacheTtl;
}
