import 'package:flutter/foundation.dart';

import '../features/deals/data/firestore_deal_repository.dart';
import '../features/deals/domain/deal.dart';

class DatabaseSeeder {
  const DatabaseSeeder(this._repo);
  final FirestoreDealRepository _repo;

  /// Writes mock deals to Firestore exactly once (no-ops if collection already
  /// has documents). Errors are caught so a missing Firebase config never
  /// crashes the app.
  Future<void> seedOnce() async {
    try {
      if (await _repo.hasDeals()) return;
      await _repo.seedDeals(_mockDeals);
      debugPrint('[DatabaseSeeder] Seeded ${_mockDeals.length} deals.');
    } catch (e) {
      debugPrint('[DatabaseSeeder] Seed skipped: $e');
    }
  }
}

final _now = DateTime.now();

final _mockDeals = <Deal>[
  // ─── MacBooks ─────────────────────────────────────────────────────────────

  Deal(
    id: 'seed_mbp16_m4max_128',
    title: 'Apple MacBook Pro 16" M4 Max · 128 GB RAM · 1 TB SSD — Space Black',
    priceEur: 3738.0,
    sourceName: 'Komplett.no',
    url: 'https://www.komplett.no/product/1234567/apple-macbook-pro-16-m4-max-128gb-1tb',
    originalCurrency: 'NOK',
    originalPrice: 49990.0,
    scrapedAt: _now,
  ),
  Deal(
    id: 'seed_mbp14_m4pro_64',
    title: 'Apple MacBook Pro 14" M4 Pro · 64 GB RAM · 1 TB SSD — Silver',
    priceEur: 2608.0,
    sourceName: 'Elkjøp.no',
    url: 'https://www.elkjop.no/product/data/mac/apple-macbook-pro-14-m4-pro-64gb-1tb-silver',
    originalCurrency: 'NOK',
    originalPrice: 36990.0,
    scrapedAt: _now,
  ),
  Deal(
    id: 'seed_mba15_m3_16gb',
    title: 'Apple MacBook Air 15" M3 · 16 GB RAM · 512 GB SSD — Midnight',
    priceEur: 1260.0,
    sourceName: 'Proshop.no',
    url: 'https://www.proshop.no/Mac/Apple-MacBook-Air-15-M3-16GB-512GB-Midnight/3219845',
    originalCurrency: 'NOK',
    originalPrice: 17490.0,
    scrapedAt: _now,
  ),

  // ─── Smartwatches ──────────────────────────────────────────────────────────

  Deal(
    id: 'seed_galaxy_watch8_classic_47',
    title: 'Samsung Galaxy Watch8 Classic 47 mm — Titanium Black',
    priceEur: 338.0,
    sourceName: 'Elkjøp.no',
    url: 'https://www.elkjop.no/product/mobil/smartklokker/samsung-galaxy-watch8-classic-47mm-titanium-black',
    originalCurrency: 'NOK',
    originalPrice: 5490.0,
    scrapedAt: _now,
  ),
  Deal(
    id: 'seed_garmin_fenix8_solar_51',
    title: 'Garmin Fēnix 8 Solar 51 mm — Carbon Grey DLC Titanium',
    priceEur: 695.0,
    sourceName: 'Komplett.no',
    url: 'https://www.komplett.no/product/1290001/garmin-fenix-8-solar-51mm-carbon-grey',
    originalCurrency: 'NOK',
    originalPrice: 10990.0,
    scrapedAt: _now,
  ),

  // ─── Audio ────────────────────────────────────────────────────────────────

  Deal(
    id: 'seed_sony_wh1000xm6_black',
    title: 'Sony WH-1000XM6 Over-Ear ANC Headphones — Midnight Black',
    priceEur: 260.0,
    sourceName: 'Komplett.no',
    url: 'https://www.komplett.no/product/1300001/sony-wh-1000xm6-midnight-black',
    originalCurrency: 'NOK',
    originalPrice: 4290.0,
    scrapedAt: _now,
  ),

  // ─── Ergonomic Chairs ─────────────────────────────────────────────────────

  Deal(
    id: 'seed_herman_miller_aeron_b',
    title: 'Herman Miller Aeron Ergonomic Chair — Size B, Graphite',
    priceEur: 1086.0,
    sourceName: 'Kontorguiden.no',
    url: 'https://www.kontorguiden.no/stoler/herman-miller-aeron-size-b-graphite',
    originalCurrency: 'NOK',
    originalPrice: 15990.0,
    scrapedAt: _now,
  ),
  Deal(
    id: 'seed_secretlab_titan_evo_2024',
    title: 'Secretlab TITAN Evo 2024 Gaming Chair — SoftWeave Plus, Stealth',
    priceEur: 490.0,
    sourceName: 'Secretlab.se',
    url: 'https://secretlab.eu/sv-se/products/titan-evo-2024?sku=TITAN-EVO-2024-STEALTH-SW',
    originalCurrency: 'SEK',
    originalPrice: 7490.0,
    scrapedAt: _now,
  ),
  Deal(
    id: 'seed_humanscale_freedom_headrest',
    title: 'Humanscale Freedom Headrest Task Chair — Black Frame / Black Leather',
    priceEur: 892.0,
    sourceName: 'Ergonomispecialisten.se',
    url: 'https://www.ergonomispecialisten.se/humanscale-freedom-headrest-task-chair-black',
    originalCurrency: 'SEK',
    originalPrice: 13490.0,
    scrapedAt: _now,
  ),

  // ─── Standing Desks ───────────────────────────────────────────────────────

  Deal(
    id: 'seed_flexispot_e7pro_160x80',
    title: 'FlexiSpot E7 Pro Height-Adjustable Standing Desk 160 × 80 cm — White',
    priceEur: 446.0,
    sourceName: 'Flexispot.se',
    url: 'https://www.flexispot.se/products/e7-pro-elektrisk-hojdinstallbart-skrivbord-160x80cm-vit',
    originalCurrency: 'SEK',
    originalPrice: 7990.0,
    scrapedAt: _now,
  ),

  // ─── Protein Supplements ──────────────────────────────────────────────────

  Deal(
    id: 'seed_on_gold_whey_isolate_227',
    title: 'Optimum Nutrition Gold Standard 100% Whey Isolate 2.27 kg — Double Rich Chocolate',
    priceEur: 47.7,
    sourceName: 'Gymgrossisten.se',
    url: 'https://www.gymgrossisten.com/on-gold-standard-whey-isolate-227kg-double-rich-chocolate',
    originalCurrency: 'NOK',
    originalPrice: 849.0,
    scrapedAt: _now,
  ),
  Deal(
    id: 'seed_myprotein_impact_isolate_5kg',
    title: 'MyProtein Impact Whey Isolate 5 kg — Natural Vanilla',
    priceEur: 62.4,
    sourceName: 'MyProtein.se',
    url: 'https://www.myprotein.com/sv-se/protein/impact-whey-isolate/10530943.html?variation=10975814',
    originalCurrency: 'SEK',
    originalPrice: 999.0,
    scrapedAt: _now,
  ),
  Deal(
    id: 'seed_bulk_creatine_mono_1kg',
    title: 'Bulk Pure Creatine Monohydrate Powder 1 kg — Unflavoured',
    priceEur: 19.6,
    sourceName: 'Bodystore.com',
    url: 'https://www.bodystore.com/kreatin/bulk-creatine-monohydrate-1kg-unflavoured/25889',
    originalCurrency: 'SEK',
    originalPrice: 349.0,
    scrapedAt: _now,
  ),

  // ─── Lifting Accessories ──────────────────────────────────────────────────

  Deal(
    id: 'seed_rogue_ohio_lifting_straps',
    title: 'Rogue Ohio Lifting Strap — Premium Cotton, Pair',
    priceEur: 31.2,
    sourceName: 'Rogue Europe',
    url: 'https://www.rogueeurope.eu/products/rogue-ohio-lifting-strap',
    originalCurrency: 'SEK',
    originalPrice: 499.0,
    scrapedAt: _now,
  ),
  Deal(
    id: 'seed_harbinger_biggrip_pro_straps',
    title: 'Harbinger Big Grip Pro Lifting Straps — Non-Slip Neoprene, Pair',
    priceEur: 15.6,
    sourceName: 'Proteinfabrikken.no',
    url: 'https://www.proteinfabrikken.no/treningsutstyr/harbinger-big-grip-pro-lifting-straps/p90215',
    originalCurrency: 'NOK',
    originalPrice: 279.0,
    scrapedAt: _now,
  ),
];
