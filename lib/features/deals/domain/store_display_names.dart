/// Maps a `deal.source` value (== `products.feed_region`, in turn ==
/// `StoreConfig.id` in scraper/scraper.py — e.g. "dyson_se") to the
/// human-readable store name a real person should see (e.g. "Dyson Sweden").
///
/// The nice name is actually computed once already, server-side
/// (`StoreConfig.name`), but scraper.py's `write_deals` only ever persists
/// `store.id` into `products.feed_region` — the name is discarded before it
/// reaches Postgres, so every API response (and this app's `Deal.source`,
/// and this app's SEO JSON-LD `brand`/`seller` fields) only ever sees the
/// raw id. Rather than a DB migration to carry the name through, this is a
/// small, stable list kept in sync manually with `STORES` in
/// scraper/scraper.py — the same pattern `functions/main.py`'s
/// `BRAND_PAGES` already uses for the same "Python backend and Dart
/// frontend can't share a single source of truth" reason.
const Map<String, String> _storeDisplayNames = {
  'acer_se': 'Acer Sweden',
  'samsung_se': 'Samsung Sweden',
  'navimow_se': 'Navimow Sweden',
  'diamondsmile_se': 'Diamond Smile Sweden',
  'babubas_se': 'Babubas Sweden',
  'sharkninja_se': 'SharkNinja Sweden',
  'deluxehomeartshop_se': 'Deluxe Home Art Shop Sweden',
  'Bazta_se': 'Bazta Sweden',
  'perfumeza_se': 'Perfumeza Sweden',
  'plusshop_se': 'PlusShop Sweden',
  'dyson_se': 'Dyson Sweden',
  'dyson_no': 'Dyson Norway',
  'sharkninja_no': 'SharkNinja Norway',
  'acer_no': 'Acer Norway',
  'byvoks_no': 'Byvoks Norway',
  'samsung_no': 'Samsung Norway',
};

/// Returns the human-readable store name for a `deal.source`/`feed_region`
/// value. Falls back to a humanized version of the raw id (underscores to
/// spaces, title-cased) for any store added to scraper.py before this map
/// is updated, so a new feed never regresses to a literal "dyson_se"-style
/// string — just a slightly-rougher-but-still-readable one until synced.
String storeDisplayName(String feedRegion) {
  final known = _storeDisplayNames[feedRegion];
  if (known != null) return known;

  final withoutRegionSuffix = feedRegion.replaceAll(
    RegExp(r'_(se|no)$', caseSensitive: false),
    '',
  );
  final words = withoutRegionSuffix
      .split(RegExp('[_-]'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1));
  return words.isEmpty ? feedRegion : words.join(' ');
}
