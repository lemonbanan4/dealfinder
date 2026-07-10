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
];

/// O(1) slug -> config lookup for the router.
final Map<String, BrandLanding> brandLandingsBySlug = {
  for (final b in brandLandings) b.slug: b,
};
