import 'deal.dart';

/// Real electronics categories for the feed's "Categories" filter.
///
/// There is no `category` column anywhere in the pipeline (the `products`
/// table only has `product_id`/`feed_region`/`title`/`brand`/pricing/image
/// fields — see `feed_automation.py` / `scraper/scraper.py` — and the REST
/// API `Deal.fromJson` mirrors that). So instead of the previous behavior of
/// deriving pseudo-categories from `feed_region` (which just meant "Sweden
/// Deals 🇸🇪" / "Norway Deals 🇳🇴" — a country flag, not a category),
/// [categoryForDeal] classifies each deal from its title via keyword
/// matching. It's a heuristic, not authoritative data — if the backend ever
/// adds a real `category` column, prefer that over this.
const List<String> dealCategories = [
  'All',
  'Smartphones',
  'Tablets',
  'Wearables',
  'Laptops/PC',
  'Monitors',
  'TVs',
  'Audio',
  'Gaming Accessories',
  'Accessories',
  'Home Electronics',
];

/// Ordered (category, keywords) rules — first match wins, so more specific
/// categories (e.g. Tablets) are checked before broader ones that would
/// otherwise also match (e.g. a "Galaxy Tab" title also contains "galaxy").
const List<(String, List<String>)> _rules = [
  (
    'Tablets',
    ['galaxy tab', 'surfplatta', 'nettbrett', 'ipad'],
  ),
  (
    'Wearables',
    ['galaxy watch', 'watch strap', 'smarttag', 'galaxy fit', 'galaxy ring', 'smartwatch'],
  ),
  (
    'Smartphones',
    [
      'galaxy s', 'galaxy z fold', 'galaxy z flip', 'galaxy a', 'galaxy note',
      ' s24', ' s25', ' s26', 'smartphone', 'mobiltelefon', 'iphone',
    ],
  ),
  (
    'TVs',
    ['smart tv', 'qled', 'oled', 'crystal uhd', 'mini led', 'the frame', ' tv,', ' tv '],
  ),
  (
    'Audio',
    [
      'soundbar', 'earbuds', 'buds', 'hörlur', 'headset', 'noise cancelling',
      'speaker', 'högtalare', 'øretelefoner',
    ],
  ),
  (
    'Monitors',
    ['monitor', 'skärm', 'skjerm', 'bildskärm', 'spelskärm', 'buet skjerm'],
  ),
  (
    'Laptops/PC',
    [
      'laptop', 'bärbar dator', 'bærbar', 'notebook', 'aspire', 'veriton',
      'stationär', 'stasjonær', 'desktop',
    ],
  ),
  (
    'Gaming Accessories',
    ['spelkontroll', 'gaming controller', 'controller', 'gaming'],
  ),
  (
    'Accessories',
    [
      'ryggsäck', 'bæreveske', 'väska', 'case', 'cover', 'skyddshylsa',
      'adapter', 'strömsladd', 'laddare', 'charger', 'mus,', 'tangentbord',
      'skydd', 'strap',
    ],
  ),
  (
    'Home Electronics',
    [
      'projektor', 'dammsugare', 'vaskemaskin', 'kylskåp', 'clean station',
      'avtrekkshette', 'vision ai',
    ],
  ),
];

/// Classifies [deal] into one of [dealCategories] (excluding `'All'`) based
/// on keyword matches in its title. Returns `null` when nothing matches —
/// such deals still show up under the `'All'` filter, just not under any
/// specific category.
String? categoryForDeal(Deal deal) {
  final title = ' ${deal.title.toLowerCase()} ';
  for (final (category, keywords) in _rules) {
    for (final keyword in keywords) {
      if (title.contains(keyword)) return category;
    }
  }
  return null;
}
