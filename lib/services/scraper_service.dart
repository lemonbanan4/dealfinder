import 'package:html/dom.dart' show Element;
import 'package:html/parser.dart' show parse;

import '../features/currency/domain/exchange_rates.dart';
import '../features/deals/domain/deal.dart';
import '../features/deals/domain/scraper_config.dart';
import 'currency_service.dart';
import 'scraper_strategy.dart';

class ScraperService {
  const ScraperService(this._strategy, this._currency);

  final ScraperStrategy _strategy;
  final CurrencyService _currency;

  Future<List<Deal>> scrape(ScraperConfig config) async {
    final rates = await _currency.getRates();
    final html = await _strategy.fetchHtml(config.baseUrl);
    return _parse(html, config, rates);
  }

  // ── parsing ─────────────────────────────────────────────────────────────────

  List<Deal> _parse(String html, ScraperConfig config, ExchangeRates rates) {
    final items = parse(html).querySelectorAll(config.listSelector);
    final deals = <Deal>[];
    for (final item in items) {
      final deal = _extractDeal(item, config, rates);
      if (deal != null) deals.add(deal);
    }
    return deals;
  }

  Deal? _extractDeal(Element item, ScraperConfig config, ExchangeRates rates) {
    try {
      final title = item.querySelector(config.titleSelector)?.text.trim() ?? '';
      final priceRaw =
          item.querySelector(config.priceSelector)?.text.trim() ?? '';
      if (title.isEmpty || priceRaw.isEmpty) return null;

      final url = _extractUrl(item, config);
      final imageUrl = _extractImageUrl(item, config);

      final priceLocal = _currency.parsePrice(priceRaw);
      if (priceLocal == null || priceLocal <= 0) return null;

      final priceEur = _toEur(priceLocal, config.currencyCode, rates);

      return Deal(
        id: _stableId(config.id, url.isNotEmpty ? url : title),
        title: title,
        priceEur: priceEur,
        sourceName: config.name,
        url: url,
        imageUrl: imageUrl,
        originalCurrency: config.currencyCode,
        originalPrice: priceLocal,
        scrapedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  String _extractUrl(Element item, ScraperConfig config) {
    final el = item.querySelector(config.linkSelector);
    if (el == null) return '';
    final href = el.attributes['href'] ??
        el.querySelector('a')?.attributes['href'] ??
        '';
    return _resolveUrl(href, config.baseUrl);
  }

  String? _extractImageUrl(Element item, ScraperConfig config) {
    final sel = config.imageSelector;
    if (sel == null) return null;
    final el = item.querySelector(sel);
    return el?.attributes['src'] ??
        el?.attributes['data-src'] ??
        el?.attributes['data-lazy-src'];
  }

  String _resolveUrl(String href, String baseUrl) {
    if (href.isEmpty) return '';
    if (href.startsWith('http')) return href;
    if (href.startsWith('//')) return 'https:$href';
    try {
      return Uri.parse(baseUrl).resolve(href).toString();
    } catch (_) {
      return href;
    }
  }

  double _toEur(double amount, String currency, ExchangeRates rates) {
    if (currency == 'EUR') return amount;
    final rate = rates.rates[currency];
    if (rate == null || rate == 0) return amount;
    return amount / rate;
  }

  /// Stable, URL-safe ID derived from source ID + content key.
  String _stableId(String sourceId, String key) =>
      '${sourceId}_${key.hashCode.abs().toRadixString(16)}';
}
