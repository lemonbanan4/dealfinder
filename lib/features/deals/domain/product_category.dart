import 'deal.dart';

/// General-marketplace categories for the feed's "Categories" filter — not
/// just electronics. Many of these have zero matches in the current catalog
/// (which is electronics-heavy today), same as the brand section before it
/// had curated data: the taxonomy is deliberately broader than what's in
/// stock right now, per PrisPuls's own positioning ("electronics, home
/// goods, fashion, and more" — see about_us_page.dart).
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
  // Electronics — the bulk of today's actual inventory.
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
  // General marketplace categories.
  'Fashion & Clothing',
  'Beauty & Health',
  'Home & Garden',
  'Sports & Outdoors',
  'Toys & Kids',
  'Groceries & Food',
  'Automotive',
  'Books & Media',
  'Pets',
  'Travel & Luggage',
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
  (
    'Fashion & Clothing',
    [
      'jacka', 'klänning', 'kappa', 'jeans', 't-shirt', 'skjorta', 'tröja',
      'byxor', 'skor', 'sko ', 'sneakers', 'kofte', 'bukse',
    ],
  ),
  (
    'Beauty & Health',
    [
      'parfym', 'hudvård', 'smink', 'schampo', 'hälsa', 'hudkrem', 'makeup',
      'vitamin', 'kosttilskudd',
    ],
  ),
  (
    'Home & Garden',
    [
      'möbel', 'møbel', 'soffa', 'sofa', 'lampa', 'lampe', 'trädgård',
      'hage', 'gräsklippare', 'gressklipper', 'köksmaskin',
    ],
  ),
  (
    'Sports & Outdoors',
    [
      'cykel', 'sykkel', 'gymutstyr', 'fitness', 'skidor', 'ski ',
      'friluftsliv', 'tält', 'telt', 'treningsutstyr',
    ],
  ),
  (
    'Toys & Kids',
    ['leksak', 'leke', 'barnvagn', 'barnevogn', 'lego', 'docka', 'dukke'],
  ),
  (
    'Groceries & Food',
    ['kaffe', 'choklad', 'sjokolade', 'dryck', 'drikke', 'matvarer'],
  ),
  (
    'Automotive',
    ['motorolja', 'motorolje', 'däck', 'dekk', 'bilstol', 'billader'],
  ),
  (
    'Books & Media',
    ['roman', 'bokbok', ' bok ', ' bok,', 'blu-ray', 'dvd '],
  ),
  (
    'Pets',
    ['hundmat', 'hundefôr', 'kattmat', 'kattemat', 'husdjur', 'kjæledyr'],
  ),
  (
    'Travel & Luggage',
    ['resväska', 'koffert', 'reisekoffert', 'handbagage'],
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
