import 'package:flutter/foundation.dart';

import '../features/deals/data/firestore_deal_repository.dart';
import '../features/deals/domain/deal.dart';

class DatabaseSeeder {
  //   const DatabaseSeeder(this._repo);
  //   final FirestoreDealRepository _repo;

  //   Future<void> reseed() async {
  //     try {
  //       await _repo.clearDeals();
  //       await _repo.seedDeals(_mockDeals);
  //       debugPrint('[DatabaseSeeder] Reseeded ${_mockDeals.length} deals.');
  //     } catch (e) {
  //       debugPrint('[DatabaseSeeder] Reseed failed: $e');
  //     }
  //   }

  //   Future<void> seedOnce() async {
  //     try {
  //       if (await _repo.hasDeals()) return;
  //       await _repo.seedDeals(_mockDeals);
  //       debugPrint('[DatabaseSeeder] Seeded ${_mockDeals.length} deals.');
  //     } catch (e) {
  //       debugPrint('[DatabaseSeeder] Seed skipped: $e');
  //     }
  //   }
}

String _unsplash(String id) =>
    'https://images.unsplash.com/photo-$id?w=400&fit=crop&auto=format&q=80';

final _mockDeals = <Deal>[
  // ─── MacBooks ──────────────────────────────────────────────────────────────
  Deal(
    id: 'seed_mbp16_m4max_128',
    title: 'Apple MacBook Pro 16" M4 Max · 128 GB RAM · 1 TB SSD — Space Black',
    source: 'Komplett.no',
    url:
        'https://www.komplett.no/product/1234567/apple-macbook-pro-16-m4-max-128gb-1tb',
    currentPrice: 49990.0,
    currency: 'NOK',
    originalPrice: null,
    imageUrl: _unsplash('1496181133206-80ce9b88a853'),
  ),
  Deal(
    id: 'seed_mbp14_m4pro_64',
    title: 'Apple MacBook Pro 14" M4 Pro · 64 GB RAM · 1 TB SSD — Silver',
    source: 'Elkjøp.no',
    url:
        'https://www.elkjop.no/product/data/mac/apple-macbook-pro-14-m4-pro-64gb-1tb-silver',
    currentPrice: 36990.0,
    currency: 'NOK',
    originalPrice: null,
    imageUrl: _unsplash('1531297484001-80022131f5a1'),
  ),
  Deal(
    id: 'seed_mba15_m3_16gb',
    title: 'Apple MacBook Air 15" M3 · 16 GB RAM · 512 GB SSD — Midnight',
    source: 'Proshop.no',
    url:
        'https://www.proshop.no/Mac/Apple-MacBook-Air-15-M3-16GB-512GB-Midnight/3219845',
    currentPrice: 17490.0,
    currency: 'NOK',
    originalPrice: null,
    imageUrl: _unsplash('1517694712202-14dd9538aa97'),
  ),

  // ─── Smartwatches ──────────────────────────────────────────────────────────
  Deal(
    id: 'seed_galaxy_watch8_classic_47',
    title: 'Samsung Galaxy Watch8 Classic 47 mm — Titanium Black',
    source: 'Elkjøp.no',
    url:
        'https://www.elkjop.no/product/mobil/smartklokker/samsung-galaxy-watch8-classic-47mm-titanium-black',
    currentPrice: 5490.0,
    currency: 'NOK',
    originalPrice: null,
    imageUrl: _unsplash('1546868871-7041f2a55e12'),
  ),
  Deal(
    id: 'seed_garmin_fenix8_solar_51',
    title: 'Garmin Fēnix 8 Solar 51 mm — Carbon Grey DLC Titanium',
    source: 'Komplett.no',
    url:
        'https://www.komplett.no/product/1290001/garmin-fenix-8-solar-51mm-carbon-grey',
    currentPrice: 10990.0,
    currency: 'NOK',
    originalPrice: null,
    imageUrl: _unsplash('1508685096597-3d102b1aa54d'),
  ),

  // ─── Audio ────────────────────────────────────────────────────────────────
  Deal(
    id: 'seed_sony_wh1000xm6_black',
    title: 'Sony WH-1000XM6 Over-Ear ANC Headphones — Midnight Black',
    source: 'Komplett.no',
    url:
        'https://www.komplett.no/product/1300001/sony-wh-1000xm6-midnight-black',
    currentPrice: 4290.0,
    currency: 'NOK',
    originalPrice: null,
    imageUrl: _unsplash('1505740420928-5e560c06d30e'),
  ),

  // ─── Ergonomic Chairs ─────────────────────────────────────────────────────
  Deal(
    id: 'seed_herman_miller_aeron_b',
    title: 'Herman Miller Aeron Ergonomic Chair — Size B, Graphite',
    source: 'Kontorguiden.no',
    url:
        'https://www.kontorguiden.no/stoler/herman-miller-aeron-size-b-graphite',
    currentPrice: 15990.0,
    currency: 'NOK',
    originalPrice: null,
    imageUrl: _unsplash('1555041469-a586c61ea9bc'),
  ),
  Deal(
    id: 'seed_secretlab_titan_evo_2024',
    title: 'Secretlab TITAN Evo 2024 Gaming Chair — SoftWeave Plus, Stealth',
    source: 'Secretlab.se',
    url:
        'https://secretlab.eu/sv-se/products/titan-evo-2024?sku=TITAN-EVO-2024-STEALTH-SW',
    currentPrice: 7490.0,
    currency: 'SEK',
    originalPrice: null,
    imageUrl: _unsplash('1567538096630-e7f552f09e90'),
  ),
  Deal(
    id: 'seed_humanscale_freedom_headrest',
    title:
        'Humanscale Freedom Headrest Task Chair — Black Frame / Black Leather',
    source: 'Ergonomispecialisten.se',
    url:
        'https://www.ergonomispecialisten.se/humanscale-freedom-headrest-task-chair-black',
    currentPrice: 13490.0,
    currency: 'SEK',
    originalPrice: null,
    imageUrl: _unsplash('1541558953459-fd05c5ed3c1c'),
  ),

  // ─── Standing Desks ───────────────────────────────────────────────────────
  Deal(
    id: 'seed_flexispot_e7pro_160x80',
    title:
        'FlexiSpot E7 Pro Height-Adjustable Standing Desk 160 × 80 cm — White',
    source: 'Flexispot.se',
    url:
        'https://www.flexispot.se/products/e7-pro-elektrisk-hojdinstallbart-skrivbord-160x80cm-vit',
    currentPrice: 7990.0,
    currency: 'SEK',
    originalPrice: null,
    imageUrl: _unsplash('1517245386807-bb43f82c33c4'),
  ),

  // ─── Protein Supplements ──────────────────────────────────────────────────
  Deal(
    id: 'seed_on_gold_whey_isolate_227',
    title:
        'Optimum Nutrition Gold Standard 100% Whey Isolate 2.27 kg — Double Rich Chocolate',
    source: 'Gymgrossisten.se',
    url:
        'https://www.gymgrossisten.com/on-gold-standard-whey-isolate-227kg-double-rich-chocolate',
    currentPrice: 849.0,
    currency: 'NOK',
    originalPrice: null,
    imageUrl: _unsplash('1593095948501-a26dc54b1be9'),
  ),
  Deal(
    id: 'seed_myprotein_impact_isolate_5kg',
    title: 'MyProtein Impact Whey Isolate 5 kg — Natural Vanilla',
    source: 'MyProtein.se',
    url:
        'https://www.myprotein.com/sv-se/protein/impact-whey-isolate/10530943.html?variation=10975814',
    currentPrice: 999.0,
    currency: 'SEK',
    originalPrice: null,
    imageUrl: _unsplash('1517344335823-7c603505dad8'),
  ),
  Deal(
    id: 'seed_bulk_creatine_mono_1kg',
    title: 'Bulk Pure Creatine Monohydrate Powder 1 kg — Unflavoured',
    source: 'Bodystore.com',
    url:
        'https://www.bodystore.com/kreatin/bulk-creatine-monohydrate-1kg-unflavoured/25889',
    currentPrice: 349.0,
    currency: 'SEK',
    originalPrice: null,
    imageUrl: _unsplash('1558618047-3c8c76ca7d13'),
  ),

  // ─── Lifting Accessories ──────────────────────────────────────────────────
  Deal(
    id: 'seed_rogue_ohio_lifting_straps',
    title: 'Rogue Ohio Lifting Strap — Premium Cotton, Pair',
    source: 'Rogue Europe',
    url: 'https://www.rogueeurope.eu/products/rogue-ohio-lifting-strap',
    currentPrice: 499.0,
    currency: 'SEK',
    originalPrice: null,
    imageUrl: _unsplash('1526506118085-60ce8714f8c5'),
  ),
  Deal(
    id: 'seed_harbinger_biggrip_pro_straps',
    title: 'Harbinger Big Grip Pro Lifting Straps — Non-Slip Neoprene, Pair',
    source: 'Proteinfabrikken.no',
    url:
        'https://www.proteinfabrikken.no/treningsutstyr/harbinger-big-grip-pro-lifting-straps/p90215',
    currentPrice: 279.0,
    currency: 'NOK',
    originalPrice: null,
    imageUrl: _unsplash('1534438327577-818ff2cf843a'),
  ),
];
