"""
DealFinder backend scraper
==========================
Fetches deals from Awin product feeds (Acer SE/NO) and HTML pages (Earfun),
then writes to Firestore /deals in the document shape expected by
FirestoreDealRepository in the Flutter app.

Usage
-----
    python scraper.py

Environment variables
---------------------
    GOOGLE_APPLICATION_CREDENTIALS  Path to a service-account JSON key.
                                    Omit when running on GCP (Cloud Run,
                                    Cloud Functions) — ADC is used automatically.
    SCRAPER_MIN_DISCOUNT_PCT        Minimum discount % to include a product
                                    (default: 0 — all discounted products).

Cron / Cloud Scheduler example
-------------------------------
    # Every hour at :00
    0 * * * * cd /path/to/scraper && python scraper.py >> /var/log/scraper.log 2>&1
"""

import hashlib
import io
import logging
import os
import re
import psycopg2
from psycopg2.extras import RealDictCursor
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Optional
from urllib.parse import urlparse

import pandas as pd
import requests
from bs4 import BeautifulSoup


# ── Logging ──────────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger(__name__)

# ── Constants ────────────────────────────────────────────────────────────────────

REQUEST_TIMEOUT = 30          # seconds; one broken store won't block the pipeline
FIRESTORE_BATCH_SIZE = 500    # Firestore hard limit per batch commit

MIN_DISCOUNT_PCT = float(os.environ.get("SCRAPER_MIN_DISCOUNT_PCT", "0"))

# ── Store configuration schema ───────────────────────────────────────────────────

@dataclass
class AwinConfig:
    """Configuration for stores served via Awin CSV product feeds."""
    feed_url: str
    # Optional: filter rows where the feed's 'currency' column matches this value.
    # Only needed when a single feed file mixes multiple currencies.
    currency_filter: Optional[str] = None


@dataclass
class HtmlConfig:
    """Configuration for stores scraped via HTML + BeautifulSoup."""
    url: str
    # CSS selector for the repeating product card container
    list_selector: str
    # CSS selectors resolved relative to each product card
    title_selector: str
    current_price_selector: str
    link_selector: str
    # Selector for the strikethrough / compare-at / original price (nullable)
    original_price_selector: Optional[str] = None
    image_selector: Optional[str] = None
    # Prepended to relative hrefs (leave empty for absolute hrefs)
    base_url: str = ""


@dataclass
class StoreConfig:
    id: str        # Firestore document ID prefix, e.g. "acer_se"
    name: str      # Stored as deal.source in Firestore, shown in Flutter UI
    currency: str  # ISO 4217, e.g. "SEK", "NOK", "EUR"
    awin: Optional[AwinConfig] = None
    html: Optional[HtmlConfig] = None


# ── Store configurations ──────────────────────────────────────────────────────────
#
# Add or remove stores here.  Restart / redeploy the script for changes to take
# effect.  The Awin API key is embedded in the feed URL — rotate it in Awin's
# publisher dashboard and update these strings accordingly.

STORES: list[StoreConfig] = [
    # ── Acer SE — Swedish store, prices in SEK ───────────────────────────────────
    StoreConfig(
        id="acer_se",
        name="Acer SE",
        currency="SEK",
        awin=AwinConfig(
            feed_url=(
                "https://productdata.awin.com/datafeed/download/apikey/"
                "4a61258494661ab34c07bf7f5ec68c59/fid/65995/format/csv/language/sv/"
                "delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2C"
                "merchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2C"
                "aw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2C"
                "merchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cproduct_name%2C"
                "description%2Cpromotional_text%2Cmerchant_deep_link%2Cmerchant_image_url%2C"
                "delivery_time%2Csearch_price%2Crrp_price%2Cdelivery_cost%2Ccondition%2C"
                "colour%2Ccustom_1%2Ccustom_2%2Ccustom_3%2Ccustom_4%2Ccustom_5%2C"
                "delivery_restrictions%2Cstock_status%2Ccustom_6%2Ccustom_7%2Cproduct_GTIN/"
            ),
            # No currency_filter: the SE feed is Sweden-only, all rows are SEK.
        ),
    ),

    # ── Acer NO — Norwegian store, prices in NOK ─────────────────────────────────
    StoreConfig(
        id="acer_no",
        name="Acer NO",
        currency="NOK",
        awin=AwinConfig(
            feed_url=(
                "https://productdata.awin.com/datafeed/download/apikey/"
                "4a61258494661ab34c07bf7f5ec68c59/fid/65993/format/csv/language/no/"
                "delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2C"
                "merchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2C"
                "aw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2C"
                "merchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cproduct_name%2C"
                "description%2Cpromotional_text%2Cmerchant_deep_link%2Cmerchant_image_url%2C"
                "delivery_time%2Ccurrency%2Csearch_price%2Crrp_price%2Cdelivery_cost%2C"
                "condition%2Ccolour%2Ccustom_1%2Ccustom_2%2Ccustom_4%2Ccustom_5%2C"
                "delivery_restrictions%2Cstock_status%2Ccustom_6%2Ccustom_7%2Cproduct_GTIN/"
            ),
            # This feed includes a 'currency' column — guard against multi-currency rows.
            currency_filter="NOK",
        ),
    ),

    # ── Earfun — EU store, prices in EUR ─────────────────────────────────────────
    #
    # Earfun runs on Shopify (Dawn 2.x theme).  All product listings are
    # server-side rendered, so BeautifulSoup works without a headless browser.
    #
    # If the site ever moves to a JS-first rendering approach, replace the html=
    # block with a Playwright-based fetch or a Shopify Storefront API call
    # (GET /products.json?limit=250).
    StoreConfig(
        id="earfun",
        name="Earfun",
        currency="EUR",
        html=HtmlConfig(
            url="https://www.earfun.com/collections/all",
            list_selector="li.grid__item",
            title_selector=".card__heading a, h3.card__heading a",
            # On Shopify Dawn, sale cards carry both a <s> (original) and a
            # non-struck price element inside .price__sale.
            current_price_selector=(
                ".price__sale .price-item--sale, "
                ".price__regular .price-item--regular"
            ),
            original_price_selector=(
                ".price__sale s.price-item--regular, "
                ".price__sale .price-item--compare"
            ),
            link_selector=".card__heading a, a.full-unstyled-link",
            image_selector=".card__media img",
            base_url="https://www.earfun.com",
        ),
    ),
]

# ── Helpers ───────────────────────────────────────────────────────────────────────

def get_db_connection():
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        raise ValueError("DATABASE_URL is not set")
    print(f"DEBUG: Using DATABASE_URL: {db_url}")
    # Use the connection string you got from Supabase (port 6543)
    return psycopg2.connect(os.environ.get("DATABASE_URL"), sslmode='require')


def _make_doc_id(store_id: str, product_url: str, fallback_key: str = "") -> str:
    """
    Build a stable Firestore document ID from the URL path slug.

    Using the URL slug (not a random UUID) makes repeated runs idempotent —
    the same product always maps to the same document, so `batch.set()` is a
    clean upsert rather than a duplicate insert.
    """
    path = urlparse(product_url).path.rstrip("/")
    slug = path.split("/")[-1] if path else ""
    if not slug:
        # Fall back to an MD5 hash if the URL has no meaningful path segment.
        slug = hashlib.md5((product_url or fallback_key).encode()).hexdigest()[:16]
    raw = f"{store_id}_{slug}"
    # Firestore document IDs must not contain slashes; sanitise everything else too.
    return re.sub(r"[^a-zA-Z0-9_-]", "_", raw)[:200]


def get_column(row, aliases):
    """Helper to find a value from a row using a list of possible column names."""
    for alias in aliases:
        if alias in row:
            val = row[alias]
            if pd.notna(val):
                return val
    return None


def _parse_price(text: str) -> Optional[float]:
    """
    Parse a price string into a float, handling:
      • European decimal comma: "1.299,00" or "1 299,00"
      • English decimal point: "1,299.00" or "1299.00"
      • Currency symbols / whitespace stripped automatically
    """
    t = re.sub(r"[^\d.,\s]", "", text.strip()).strip()
    if not t:
        return None

    # Remove non-breaking / regular spaces used as thousands separators.
    t = t.replace(" ", "").replace(" ", "")

    if "," in t and "." in t:
        if t.rfind(",") > t.rfind("."):
            # e.g. "1.299,00" — European format
            t = t.replace(".", "").replace(",", ".")
        else:
            # e.g. "1,299.00" — English format
            t = t.replace(",", "")
    elif "," in t:
        parts = t.split(",")
        if len(parts) == 2 and len(parts[1]) in (1, 2):
            t = t.replace(",", ".")  # decimal comma: "79,99" → "79.99"
        else:
            t = t.replace(",", "")  # thousands comma: "1,299" → "1299"

    try:
        return float(t)
    except ValueError:
        return None


def _discount_pct(original: float, current: float) -> float:
    if original <= 0:
        return 0.0
    return (original - current) / original * 100.0


# ── Awin feed fetcher ─────────────────────────────────────────────────────────────

def fetch_awin_deals(store: StoreConfig) -> list[dict]:
    """Download and parse an Awin CSV product feed; return deal dicts."""
    cfg = store.awin
    assert cfg is not None

    log.info("[%s] Downloading Awin CSV feed…", store.name)
    try:
        resp = requests.get(
            cfg.feed_url,
            headers={"Accept-Encoding": "gzip, deflate"},
            timeout=REQUEST_TIMEOUT,
        )
        resp.raise_for_status()
    except requests.exceptions.Timeout:
        log.error(
            "[%s] Awin feed timed out after %ds — skipping store.",
            store.name, REQUEST_TIMEOUT,
        )
        return []
    except requests.exceptions.RequestException as exc:
        log.error("[%s] Awin feed network error (%s) — skipping store.", store.name, exc)
        return []

    try:
        df = pd.read_csv(io.BytesIO(resp.content), compression="gzip", low_memory=False)
    except Exception as exc:
        log.error("[%s] Failed to parse Awin CSV (%s) — skipping store.", store.name, exc)
        return []

    log.info("[%s] %d raw rows received.", store.name, len(df))

    # Drop rows missing required fields.
    df = df.dropna(subset=["aw_deep_link", "search_price"])
    df["search_price"] = pd.to_numeric(df["search_price"], errors="coerce")
    df["rrp_price"] = pd.to_numeric(df["rrp_price"], errors="coerce")
    df = df.dropna(subset=["search_price"])

    # Filter to the target currency when the feed mixes multiple currencies.
    if cfg.currency_filter and "currency" in df.columns:
        df = df[df["currency"].str.upper() == cfg.currency_filter.upper()]

    # Identify rows that have a valid, higher RRP — but do NOT discard the rest.
    # Products where rrp_price is missing or ≤ search_price are kept and stored
    # with originalPrice = None so all 200+ products flow through.
    has_discount = df["rrp_price"].notna() & (df["rrp_price"] > df["search_price"])

    # SCRAPER_MIN_DISCOUNT_PCT only drops rows that *have* an RRP but fall below
    # the threshold.  Rows without any RRP are always kept.
    if MIN_DISCOUNT_PCT > 0:
        below_threshold = has_discount & (
            (df["rrp_price"] - df["search_price"]) / df["rrp_price"] * 100
            < MIN_DISCOUNT_PCT
        )
        df = df[~below_threshold]
        has_discount = df["rrp_price"].notna() & (df["rrp_price"] > df["search_price"])

    log.info(
        "[%s] %d products kept (%d with discount, %d without RRP).",
        store.name, len(df), int(has_discount.sum()), int((~has_discount).sum()),
    )

    deals: list[dict] = []
    for _, row in df.iterrows():
        # Get values using the aliases
        url = str(get_column(row, ['aw_deep_link', 'merchant_deep_link']) or "").strip()
        fallback = str(row.get("merchant_product_id", ""))
        doc_id = _make_doc_id(store.id, url, fallback_key=fallback)

        image_url = get_column(row, ['merchant_image_url', 'aw_image_url', 'alternate_image'])

        # Use the alias helper for price too
        price_val = get_column(row, ['search_price', 'product_price', 'price'])
        
        # Use the alias helper for RRP
        rrp_val = get_column(row, ['rrp_price', 'product_price_old', 'saving'])

        current_price = float(price_val) if price_val is not None else 0.0
        
        # Original price logic
        original_price = None
        if rrp_val is not None and float(rrp_val) > current_price:
            original_price = float(rrp_val)

        deals.append({
            "id": doc_id,
            "title": str(row.get("product_name", "")).strip(),
            "url": url,
            "source": store.name,
            "currentPrice": current_price,
            "currency": store.currency,
            "imageUrl": image_url,
            "originalPrice": original_price,
        })

    return deals


# ── HTML / BeautifulSoup fetcher ──────────────────────────────────────────────────

# Full browser-grade header set to pass Shopify's WAF checks.
# UNEXPECTED_EOF_WHILE_READING means Shopify closed the TLS connection on
# detecting a non-browser client.  Sec-Fetch-* headers and a realistic
# Accept-Encoding are usually enough to get through.
#
# If it still fails, the reliable fix is `curl-cffi`, which clones Chrome's
# exact TLS fingerprint (JA3 hash):
#   pip install curl-cffi
#   from curl_cffi import requests as cf
#   resp = cf.get(url, impersonate="chrome124", timeout=REQUEST_TIMEOUT)
_HTML_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": (
        "text/html,application/xhtml+xml,application/xml;q=0.9,"
        "image/avif,image/webp,image/apng,*/*;q=0.8,"
        "application/signed-exchange;v=b3;q=0.7"
    ),
    "Accept-Language": "en-US,en;q=0.9",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Cache-Control": "max-age=0",
}


def _resolve_image(img_tag) -> Optional[str]:
    """
    Extract the best image URL from a <img> tag.

    Shopify lazy-loads via data-src or a srcset attribute; BeautifulSoup sees
    the raw HTML before JavaScript runs, so we check all three attributes.
    """
    if img_tag is None:
        return None
    src = (
        img_tag.get("src")
        or img_tag.get("data-src")
        or (img_tag.get("srcset", "").split(" ")[0] if img_tag.get("srcset") else None)
    )
    if src and src.startswith("//"):
        src = "https:" + src
    return src or None


def fetch_html_deals(store: StoreConfig) -> list[dict]:
    """Scrape an HTML product listing page; return deal dicts."""
    cfg = store.html
    assert cfg is not None

    log.info("[%s] Fetching %s …", store.name, cfg.url)
    try:
        resp = requests.get(cfg.url, headers=_HTML_HEADERS, timeout=REQUEST_TIMEOUT)
        resp.raise_for_status()
    except requests.exceptions.Timeout:
        log.error(
            "[%s] Page request timed out after %ds — skipping store.",
            store.name, REQUEST_TIMEOUT,
        )
        return []
    except requests.exceptions.RequestException as exc:
        log.error("[%s] Page network error (%s) — skipping store.", store.name, exc)
        return []

    soup = BeautifulSoup(resp.text, "lxml")
    items = soup.select(cfg.list_selector)
    log.info("[%s] %d product cards found in DOM.", store.name, len(items))

    deals: list[dict] = []
    for item in items:
        title_el = item.select_one(cfg.title_selector)
        price_el = item.select_one(cfg.current_price_selector)
        link_el = item.select_one(cfg.link_selector)

        if not (title_el and price_el and link_el):
            continue

        title = title_el.get_text(strip=True)
        current_price = _parse_price(price_el.get_text())
        if current_price is None or current_price <= 0:
            continue

        href_value = link_el.get("href")
        if isinstance(href_value, list):
            href = href_value[0] if href_value else ""
        elif href_value is None:
            href = ""
        else:
            href = str(href_value)

        if href.startswith("/"):
            href = cfg.base_url + href
        if not href:
            continue

        original_price: Optional[float] = None
        if cfg.original_price_selector:
            orig_el = item.select_one(cfg.original_price_selector)
            if orig_el:
                parsed = _parse_price(orig_el.get_text())
                # Sanity check: original price must actually be higher.
                if parsed is not None and parsed > current_price:
                    original_price = parsed

        # Apply minimum discount threshold (original_price must exist for HTML stores).
        if MIN_DISCOUNT_PCT > 0:
            if original_price is None:
                continue
            if _discount_pct(original_price, current_price) < MIN_DISCOUNT_PCT:
                continue

        image_url = _resolve_image(
            item.select_one(cfg.image_selector) if cfg.image_selector else None
        )

        doc_id = _make_doc_id(store.id, href)
        deals.append({
            "id": doc_id,
            "title": title,
            "url": href,
            "source": store.name,
            "currentPrice": current_price,
            "currency": store.currency,
            "imageUrl": image_url,
            "originalPrice": original_price,
        })

    log.info("[%s] %d valid deals parsed.", store.name, len(deals))
    return deals


# ── Firestore writer ──────────────────────────────────────────────────────────────

# 1. Update the signature to accept the store ID
def write_deals(deals: list[dict], store_id: str) -> int:
    conn = get_db_connection()
    cur = conn.cursor()
    
    upsert_query = """
    INSERT INTO products (
        product_id, feed_region, title, brand, price, 
        retail_price, tracking_url, image_url, description, 
        stock_status, ean_code
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    ON CONFLICT (product_id) 
    DO UPDATE SET 
        price = EXCLUDED.price,
        retail_price = EXCLUDED.retail_price,
        stock_status = EXCLUDED.stock_status,
        last_updated = timezone('utc'::text, now());
    """
    
    for deal in deals:
        cur.execute(upsert_query, (
            deal["id"], 
            store_id,  # Use the dynamic store ID passed here
            deal["title"], 
            "Acer", # Note: You might want to make this dynamic too!
            deal["currentPrice"],
            deal["originalPrice"], 
            deal["url"], 
            deal["imageUrl"], 
            "", 
            "In Stock", 
            None
        ))
    
    conn.commit()
    cur.close()
    conn.close()
    return len(deals)

# ── Per-store dispatch ────────────────────────────────────────────────────────────

def scrape_store(store: StoreConfig) -> list[dict]:
    if store.awin:
        return fetch_awin_deals(store)
    if store.html:
        return fetch_html_deals(store)
    log.warning("[%s] No awin or html config defined — skipped.", store.name)
    return []


# ── Entry point ───────────────────────────────────────────────────────────────────

def main() -> None:
    # # ── Firebase Admin SDK init ───────────────────────────────────────────────────
    # cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    # if cred_path:
    #     cred = credentials.Certificate(cred_path)
    #     firebase_admin.initialize_app(cred)
    #     log.info("Firebase initialised with service account: %s", cred_path)
    # else:
    #     firebase_admin.initialize_app()
    #     log.info("Firebase initialised using Application Default Credentials.")

    # db = firestore.client()

    # ── Scrape and Write Store by Store ──────────────────────────────────────────
    for store in STORES:
        try:
            deals = scrape_store(store)
            if deals:
                log.info("[%s] Writing %d deals to Supabase...", store.name, len(deals))
                written = write_deals(deals, store.id) # Pass the store ID here
                log.info("[%s] Successfully wrote %d deals.", store.name, written)
        except Exception as exc:
            log.exception("[%s] Unexpected error — store skipped: %s", store.name, exc)

    log.info("Pipeline complete.")


if __name__ == "__main__":
    main()
