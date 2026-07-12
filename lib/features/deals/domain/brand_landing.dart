/// Config for one SEO-targeted "Best Deals on {brand} in {region}" landing
/// page. [storeFeed] must be an exact `products.feed_region` value with
/// real, dedicated tracked inventory (see StoreConfig in scraper/scraper.py)
/// — deliberately not the client-side title/feed_region substring search
/// the homepage's "Utvalda Brands" tiles use, which can (and did — see the
/// removed JBL tile) point at brands with zero actual matching products.
/// Confirmed live via a direct DB check before adding each entry here.
class BrandLanding {
  const BrandLanding({
    required this.slug,
    required this.brandName,
    required this.regionName,
    required this.storeFeed,
  });

  final String slug;
  final String brandName;
  final String regionName;
  final String storeFeed;

  String get title => 'Best Deals on $brandName in $regionName';
}

/// All current brand landing pages — the definitive list for routing,
/// the sitemap, and internal links alike.
const brandLandings = <BrandLanding>[
  BrandLanding(
    slug: 'dyson-sweden',
    brandName: 'Dyson',
    regionName: 'Sweden',
    storeFeed: 'dyson_se',
  ),
  BrandLanding(
    slug: 'dyson-norway',
    brandName: 'Dyson',
    regionName: 'Norway',
    storeFeed: 'dyson_no',
  ),
  BrandLanding(
    slug: 'samsung-sweden',
    brandName: 'Samsung',
    regionName: 'Sweden',
    storeFeed: 'samsung_se',
  ),
  BrandLanding(
    slug: 'samsung-norway',
    brandName: 'Samsung',
    regionName: 'Norway',
    storeFeed: 'samsung_no',
  ),
  BrandLanding(
    slug: 'acer-sweden',
    brandName: 'Acer',
    regionName: 'Sweden',
    storeFeed: 'acer_se',
  ),
  BrandLanding(
    slug: 'acer-norway',
    brandName: 'Acer',
    regionName: 'Norway',
    storeFeed: 'acer_no',
  ),
  BrandLanding(
    slug: 'sharkninja-sweden',
    brandName: 'SharkNinja',
    regionName: 'Sweden',
    storeFeed: 'sharkninja_se',
  ),
  BrandLanding(
    slug: 'sharkninja-norway',
    brandName: 'SharkNinja',
    regionName: 'Norway',
    storeFeed: 'sharkninja_no',
  ),
  BrandLanding(
    slug: 'diamond-smile-sweden',
    brandName: 'Diamond Smile',
    regionName: 'Sweden',
    storeFeed: 'diamondsmile_se',
  ),
  BrandLanding(
    slug: 'babubas-sweden',
    brandName: 'Babubas',
    regionName: 'Sweden',
    storeFeed: 'babubas_se',
  ),
  BrandLanding(
    slug: 'deluxe-home-art-shop-sweden',
    brandName: 'Deluxe Home Art Shop',
    regionName: 'Sweden',
    storeFeed: 'deluxehomeartshop_se',
  ),
  BrandLanding(
    slug: 'bazta-sweden',
    brandName: 'Bazta',
    regionName: 'Sweden',
    storeFeed: 'Bazta_se',
  ),
  BrandLanding(
    slug: 'perfumeza-sweden',
    brandName: 'Perfumeza',
    regionName: 'Sweden',
    storeFeed: 'perfumeza_se',
  ),
  BrandLanding(
    slug: 'plusshop-sweden',
    brandName: 'PlusShop',
    regionName: 'Sweden',
    storeFeed: 'plusshop_se',
  ),
  BrandLanding(
    slug: 'byvoks-norway',
    brandName: 'Byvoks',
    regionName: 'Norway',
    storeFeed: 'byvoks_no',
  ),
  // navimow_se is deliberately excluded: confirmed zero live products via
  // /api/deals/by-store as of 2026-07-12 — the same "landing page pointing
  // at a dead feed" trap the removed JBL tile hit (see the class doc
  // comment above). Add it back once/if the feed has real inventory again.
];

/// O(1) slug -> config lookup for the router.
final Map<String, BrandLanding> brandLandingsBySlug = {
  for (final b in brandLandings) b.slug: b,
};

/// Finds a [BrandLanding] by brand name (case-insensitive) and region code
/// ('se'/'no', matching `regionProvider`'s values in feed_page.dart) — used
/// to send a brand-tile tap straight to its SEO landing page when one
/// exists for the shopper's current region, rather than just filtering the
/// feed in place.
BrandLanding? brandLandingFor(String brandName, String regionCode) {
  final regionName = regionCode.toLowerCase() == 'no' ? 'Norway' : 'Sweden';
  for (final landing in brandLandings) {
    if (landing.brandName.toLowerCase() == brandName.toLowerCase() &&
        landing.regionName == regionName) {
      return landing;
    }
  }
  return null;
}
