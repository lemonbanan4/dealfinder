import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

abstract final class HiveBoxes {
  static const deals = 'deals';
  static const alerts = 'alerts';
  static const settings = 'settings';
  static const currencyRates = 'currency_rates';
  static const scraperConfigs = 'scraper_configs';
}

abstract final class ApiUrls {
  static const ecbRates =
      'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml';

  // Use a proper production URL here.
  // Once you deploy to Render, swap this:
  static const String apiUrl = kReleaseMode
      ? 'https://your-render-url.onrender.com'
      : 'http://127.0.0.1:8000';
}

abstract final class CurrencyCode {
  static const eur = 'EUR';
  static const nok = 'NOK';
  static const sek = 'SEK';
  static const usd = 'USD';

  static const supported = [eur, nok, sek, usd];
}

const ratesCacheTtl = Duration(hours: 6);
