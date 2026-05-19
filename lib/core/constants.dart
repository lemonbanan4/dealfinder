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
  static const erApiRates = 'https://open.er-api.com/v6/latest/EUR';
  // BFF proxy used by the web/WASM build (configure to your deployed shelf service).
  static const bffBase = 'http://localhost:8080';
}

abstract final class CurrencyCode {
  static const eur = 'EUR';
  static const nok = 'NOK';
  static const sek = 'SEK';
  static const usd = 'USD';

  static const supported = [eur, nok, sek, usd];
}

const ratesCacheTtl = Duration(hours: 6);
