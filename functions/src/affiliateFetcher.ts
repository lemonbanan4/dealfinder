import {logger} from "firebase-functions";

export interface DealPayload {
  id: string;
  title: string;
  priceEur: number;
  sourceName: string;
  url: string;
  imageUrl: string | null;
  originalCurrency: string;
  originalPrice: number;
}

/**
 * Stub affiliate fetcher. Replace fetchDeals() body with live
 * Adtraction / Awin API calls when credentials are available.
 */
export class AffiliateFetcher {
  /**
   * Returns the current set of deals from affiliate networks.
   * Replace this body with live Adtraction / Awin API calls.
   * @return {Promise<DealPayload[]>} Array of deal payloads.
   */
  async fetchDeals(): Promise<DealPayload[]> {
    logger.info("AffiliateFetcher: returning stub deal set");

    return [
      {
        id: "aff-apple-mbp-m4-14",
        title: "Apple MacBook Pro 14\" M4 Pro — Space Black",
        priceEur: 1999.0,
        originalCurrency: "NOK",
        originalPrice: 24990.0,
        sourceName: "Elkjøp",
        url: "https://www.elkjop.no/product/macbook-pro-14-m4-pro",
        imageUrl: "https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/mbp14-spaceblack-select-202410",
      },
      {
        id: "aff-apple-mbp-m4-16",
        title: "Apple MacBook Pro 16\" M4 Max — Silver",
        priceEur: 2799.0,
        originalCurrency: "NOK",
        originalPrice: 34990.0,
        sourceName: "Power",
        url: "https://www.power.no/produkt/macbook-pro-16-m4-max",
        // eslint-disable-next-line max-len
        imageUrl: "https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/mbp16-silver-select-202410",
      },
      {
        id: "aff-apple-mba-m3-15",
        title: "Apple MacBook Air 15\" M3 — Midnight",
        priceEur: 1349.0,
        originalCurrency: "SEK",
        originalPrice: 16990.0,
        sourceName: "Webhallen",
        url: "https://www.webhallen.com/se/product/macbook-air-15-m3",
        imageUrl: "https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/mba15-midnight-select-202402",
      },
      {
        id: "aff-rogue-ob-bar",
        title: "Rogue Ohio Bar — Cerakote Black",
        priceEur: 395.0,
        originalCurrency: "EUR",
        originalPrice: 445.0,
        sourceName: "Rogue Europe",
        url: "https://www.roguefitness.com/eu/rogue-ohio-bar-cerakote",
        imageUrl: "https://assets.roguefitness.com/f_auto,q_auto,w_800/catalog/Barbells/Olympic%20Barbells/ob-black-cerakote-web3.png",
      },
      {
        id: "aff-rogue-monster-rack",
        title: "Rogue Monster Lite HR-2 Half Rack",
        priceEur: 899.0,
        originalCurrency: "EUR",
        originalPrice: 1050.0,
        sourceName: "Rogue Europe",
        url: "https://www.roguefitness.com/eu/rogue-hr-2-half-rack",
        imageUrl: "https://assets.roguefitness.com/f_auto,q_auto,w_800/catalog/Racks-and-Systems/Rogue-HR-2-Half-Rack-Hero.png",
      },
      {
        id: "aff-on-gold-standard-whey",
        // eslint-disable-next-line max-len
        title: "Optimum Nutrition Gold Standard 100% Whey Isolate — Double Rich Chocolate 2.27 kg",
        priceEur: 54.9,
        originalCurrency: "NOK",
        originalPrice: 649.0,
        sourceName: "Bodylab",
        url: "https://www.bodylab.no/shop/optimum-nutrition-gold-standard-whey-isolate",
        imageUrl: "https://www.bodylab.no/images/products/on-gold-standard-whey-isolate-drc.jpg",
      },
      {
        id: "aff-samsung-qn90d-65",
        title: "Samsung Neo QLED QN90D 65\" 4K 144 Hz",
        priceEur: 1299.0,
        originalCurrency: "SEK",
        originalPrice: 16999.0,
        sourceName: "Elgiganten",
        url: "https://www.elgiganten.se/product/samsung-qn90d-65",
        imageUrl: "https://images.samsung.com/se/tvs/neo-qled-tv/qn90d/2024/QN65QN90DATXXC_001_Front_Black.jpg",
      },
      {
        id: "aff-sony-wh1000xm6",
        title: "Sony WH-1000XM6 Wireless Noise Cancelling Headphones",
        priceEur: 299.0,
        originalCurrency: "EUR",
        originalPrice: 349.0,
        sourceName: "Sony Store",
        url: "https://www.sony.com/en/headphones/wh-1000xm6",
        imageUrl: "https://www.sony.com/image/wh1000xm6-front-black.jpg",
      },
      {
        id: "aff-garmin-fenix8-solar",
        title: "Garmin Fēnix 8 Solar 47mm — Carbon Grey",
        priceEur: 849.0,
        originalCurrency: "NOK",
        originalPrice: 10990.0,
        sourceName: "XXL Sport",
        url: "https://www.xxl.no/garmin-fenix-8-solar",
        imageUrl: "https://static.garmincdn.com/com.garmin/products/fenix8-solar-carbon.png",
      },
      {
        id: "aff-nobull-trainer-plus",
        title: "NOBULL Trainer+ — Triple Black",
        priceEur: 129.0,
        originalCurrency: "EUR",
        originalPrice: 150.0,
        sourceName: "NOBULL EU",
        url: "https://eu.nobull.com/products/trainer-plus-triple-black",
        imageUrl: "https://eu.nobull.com/cdn/shop/products/trainer-plus-triple-black-hero.jpg",
      },
      {
        id: "aff-ipad-pro-m4-13",
        title: "Apple iPad Pro 13\" M4 Wi-Fi 256 GB — Space Black",
        priceEur: 1299.0,
        originalCurrency: "SEK",
        originalPrice: 16490.0,
        sourceName: "Webhallen",
        url: "https://www.webhallen.com/se/product/ipad-pro-13-m4-space-black",
        imageUrl: "https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/ipadpro-spaceblack-select-202405",
      },
      {
        id: "aff-concept2-rowerg",
        title: "Concept2 RowErg Indoor Rower — Black PM5",
        priceEur: 1049.0,
        originalCurrency: "NOK",
        originalPrice: 13490.0,
        sourceName: "Concept2 EU",
        url: "https://www.concept2.com/eu/indoor-rowers/rowerg",
        imageUrl: "https://www.concept2.com/files/images/products/rowerg-black.jpg",
      },
      {
        id: "aff-lg-gram-16-2025",
        title: "LG Gram 16 (2025) Ultra 7 — White 32 GB / 1 TB",
        priceEur: 1449.0,
        originalCurrency: "SEK",
        originalPrice: 18990.0,
        sourceName: "NetOnNet",
        url: "https://www.netonnet.se/product/lg-gram-16-2025",
        imageUrl: "https://www.lg.com/se/images/laptops/gram16-2025-white-hero.jpg",
      },
      {
        id: "aff-corsair-k100-rgb",
        title: "Corsair K100 RGB Optical-Mechanical Gaming Keyboard",
        priceEur: 189.0,
        originalCurrency: "EUR",
        originalPrice: 229.0,
        sourceName: "Corsair EU",
        url: "https://www.corsair.com/eu/en/keyboard/k100-rgb",
        imageUrl: "https://www.corsair.com/medias/sys_master/images/k100-rgb-keyboard-hero.jpg",
      },
      {
        id: "aff-theragun-pro-gen6",
        title: "Theragun PRO Gen 6 Percussive Therapy Device",
        priceEur: 479.0,
        originalCurrency: "NOK",
        originalPrice: 5999.0,
        sourceName: "SportShop",
        url: "https://www.sportshop.no/theragun-pro-gen-6",
        imageUrl: "https://cdn.therabody.com/theragun-pro-gen6-hero.jpg",
      },
    ];
  }
}
