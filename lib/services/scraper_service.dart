import 'dart:developer';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:uuid/uuid.dart';

import '../features/deals/domain/deal.dart';
import '../features/deals/domain/scraper_config.dart';
import 'currency_service.dart';
import 'scraper_strategy.dart';

class ScraperService {
  ScraperService(this._strategy, this._currency);

  final ScraperStrategy _strategy;
  final CurrencyService _currency;

  static const _uuid = Uuid();
  // RFC 4122 §4.3 URL namespace — used for deterministic v5 UUIDs.
  static const _urlNamespace = '6ba7b811-9dad-11d1-80b4-00c04fd430c8';
  // Hard cap to prevent runaway pagination on misconfigured selectors.
  static const _maxPages = 5;

  Future<List<Deal>> scrape(ScraperConfig config) async {
    final deals = <Deal>[];
    var url = config.baseUrl;

    for (var page = 0; page < _maxPages; page++) {
      final html = await _strategy.fetchHtml(url);
      final document = html_parser.parse(html);
      final items = document.querySelectorAll(config.listSelector);

      // On the first page, zero matches is a hard signal the site markup changed.
      if (items.isEmpty && page == 0) {
        throw Exception(
          'listSelector "${config.listSelector}" matched 0 elements on $url — '
          'site markup may have changed',
        );
      }

      for (final item in items) {
        final deal = _parseDeal(item, config);
        if (deal != null) deals.add(deal);
      }

      if (config.nextPageSelector == null) break;
      final nextHref = document
          .querySelector(config.nextPageSelector!)
          ?.attributes['href'];
      if (nextHref == null || nextHref.isEmpty) break;
      url = _resolve(config.baseUrl, nextHref);
    }

    return deals;
  }

  Deal? _parseDeal(Element item, ScraperConfig config) {
    final title =
        item.querySelector(config.titleSelector)?.text.trim() ?? '';
    final priceRaw =
        item.querySelector(config.priceSelector)?.text.trim() ?? '';
    final href =
        item.querySelector(config.linkSelector)?.attributes['href'] ?? '';

    if (title.isEmpty || href.isEmpty) return null;

    final price = _currency.parsePrice(priceRaw);
    if (price == null) {
      // Log individually so the developer can tune the selector without
      // failing the entire scrape run for this config.
      log(
        'Skipping item — could not parse price from "$priceRaw" '
        '(selector: "${config.priceSelector}")',
        name: 'ScraperService:${config.name}',
      );
      return null;
    }

    final url = _resolve(config.baseUrl, href);

    String? imageUrl;
    if (config.imageSelector case final sel?) {
      final el = item.querySelector(sel);
      // Try src first, then data-src for lazy-loaded images.
      final src = el?.attributes['src'] ?? el?.attributes['data-src'] ?? '';
      if (src.isNotEmpty) imageUrl = _resolve(config.baseUrl, src);
    }

    return Deal(
      // v5 UUID is deterministic on URL so the same product maps to the same
      // ID across scrape runs, keeping Hive deduplication stable.
      id: _uuid.v5(_urlNamespace, url),
      title: title,
      url: url,
      source: config.name,
      currentPrice: price,
      currency: config.currencyCode,
      imageUrl: imageUrl,
    );
  }

  // Uri.resolve handles both absolute and relative hrefs correctly.
  String _resolve(String base, String href) =>
      Uri.parse(base).resolve(href).toString();
}
