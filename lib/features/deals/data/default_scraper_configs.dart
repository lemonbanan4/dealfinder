import '../domain/scraper_config.dart';

/// Seed configs bundled with the app.
///
/// All ship with [isEnabled] = false — users enable them in Settings after
/// verifying that the selectors still match the live site's markup.
final defaultScraperConfigs = <ScraperConfig>[
  // ── Finn.no Torget (Norway, NOK) ─────────────────────────────────────────
  ScraperConfig(
    id: 'finn_no_torget',
    name: 'Finn.no Torget',
    baseUrl: 'https://www.finn.no/recommerce/forsale/search.html',
    listSelector: 'article[data-testid="ad-list-item"]',
    titleSelector: 'h2[data-testid="ad-title"]',
    priceSelector: '[data-testid="listing-price"]',
    linkSelector: 'a[href]',
    imageSelector: 'img[src]',
    currencyCode: 'NOK',
    isEnabled: false,
  ),

  // ── Blocket.se (Sweden, SEK) ─────────────────────────────────────────────
  ScraperConfig(
    id: 'blocket_se',
    name: 'Blocket.se',
    baseUrl: 'https://www.blocket.se/annonser/hela_sverige',
    listSelector: '[data-testid="listing-card"]',
    titleSelector: '[data-testid="listing-card-title"]',
    priceSelector: '[data-testid="listing-card-price"]',
    linkSelector: 'a[href]',
    imageSelector: 'img',
    currencyCode: 'SEK',
    isEnabled: false,
  ),

  // ── Prisjakt.no — electronics (Norway, NOK) ───────────────────────────────
  ScraperConfig(
    id: 'prisjakt_no',
    name: 'Prisjakt.no',
    baseUrl: 'https://www.prisjakt.no/category.php?k=5031',
    listSelector: '.products-list__item',
    titleSelector: '.product-card__name',
    priceSelector: '.product-card__price-current',
    linkSelector: 'a.product-card__link',
    imageSelector: 'img.product-card__image',
    currencyCode: 'NOK',
    isEnabled: false,
  ),
];
