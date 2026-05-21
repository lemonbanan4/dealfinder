import dotenv from "dotenv";
import axios from "axios";
import {logger} from "firebase-functions";

dotenv.config();

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

// ── Awin API response shapes ─────────────────────────────────────────────────

interface AwinRegion {
  name: string;
  isPrimary?: boolean;
}

interface AwinMerchant {
  id: number;
  name: string;
  primaryRegion?: AwinRegion;
  logoUrl?: string;
}

interface AwinDiscount {
  amount?: number;
  // "percent" | "absolute"
  type?: string;
}

interface AwinPromotion {
  promotionId: number;
  title: string;
  discount?: AwinDiscount | null;
  regions?: AwinRegion[];
  merchant?: AwinMerchant;
  deepLink?: string;
  displayUrl?: string;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

const AWIN_API_BASE = "https://api.awin.com";

const REGION_CURRENCY: Record<string, string> = {
  NO: "NOK", SE: "SEK", DK: "DKK", FI: "EUR",
  DE: "EUR", FR: "EUR", AT: "EUR", NL: "EUR",
  GB: "GBP", US: "USD",
};

/**
 * Maps a raw Awin promotion to our internal DealPayload schema.
 * Returns null when required fields (merchant, affiliate link) are absent.
 * Promotions carry discount metadata but not an explicit retail price;
 * priceEur and originalPrice are set to 0 as sentinels — replace with
 * product-feed data once feed IDs are configured.
 * @param {AwinPromotion} promo Raw Awin promotion response object.
 * @return {DealPayload | null} Mapped deal, or null if unmappable.
 */
function mapPromotion(promo: AwinPromotion): DealPayload | null {
  const merchant = promo.merchant;
  const link = promo.deepLink ?? promo.displayUrl;
  if (!merchant || !link) return null;

  const region =
    promo.regions?.find((r) => r.isPrimary)?.name ??
    promo.regions?.[0]?.name ??
    merchant.primaryRegion?.name ??
    "DE";

  const currency = REGION_CURRENCY[region] ?? "EUR";

  return {
    id: `awin-${promo.promotionId}`,
    title: promo.title,
    priceEur: 0,
    sourceName: merchant.name,
    url: link,
    imageUrl: merchant.logoUrl ?? null,
    originalCurrency: currency,
    originalPrice: 0,
  };
}

// ── AffiliateFetcher ─────────────────────────────────────────────────────────

/** Pulls live deals from the Awin Publisher Promotions API. */
export class AffiliateFetcher {
  private readonly token: string;
  private readonly publisherId: string;

  /**
   * Initializes the fetcher with Awin credentials from environment.
   * Throws if AWIN_API_TOKEN or AWIN_PUBLISHER_ID is not set.
   */
  constructor() {
    const token = process.env.AWIN_API_TOKEN;
    const publisherId = process.env.AWIN_PUBLISHER_ID;
    if (!token || !publisherId) {
      throw new Error(
        "AWIN_API_TOKEN and AWIN_PUBLISHER_ID must be set in .env",
      );
    }
    this.token = token;
    this.publisherId = publisherId;
  }

  /**
   * Fetches current deals from the Awin Promotions API.
   * Filters to Nordic/DACH regions by default. On network error
   * or rate limit, logs the error and returns an empty array so
   * the cron job continues without crashing.
   * @return {Promise<DealPayload[]>} Array of mapped deal payloads.
   */
  async fetchDeals(): Promise<DealPayload[]> {
    try {
      const url =
        `${AWIN_API_BASE}/publishers/${this.publisherId}/promotions`;
      const {data} = await axios.get<AwinPromotion[]>(url, {
        headers: {Authorization: `Bearer ${this.token}`},
        params: {regionIds: "NO,SE,DK,DE,AT"},
        timeout: 15000,
      });

      const deals = data
        .map(mapPromotion)
        .filter((d): d is DealPayload => d !== null);

      logger.info(
        `AffiliateFetcher: mapped ${deals.length} deals from Awin`,
      );
      return deals;
    } catch (err) {
      logger.error("AffiliateFetcher: Awin request failed", err);
      return [];
    }
  }
}
