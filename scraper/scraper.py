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
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Optional
from urllib.parse import urlparse

import firebase_admin
import pandas as pd
import requests
from bs4 import BeautifulSoup
from firebase_admin import credentials, firestore

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
        url = str(row.get("aw_deep_link", "")).strip()
        fallback = str(row.get("merchant_product_id", ""))
        doc_id = _make_doc_id(store.id, url, fallback_key=fallback)

        image_url = (
            str(row.get("merchant_image_url") or "").strip()
            or str(row.get("aw_image_url") or "").strip()
            or None
        )

        rrp = row.get("rrp_price")
        original_price = (
            float(rrp)
            if pd.notna(rrp) and float(rrp) > float(row["search_price"])
            else None
        )

        deals.append({
            "id": doc_id,
            "title": str(row.get("product_name", "")).strip(),
            "url": url,
            "source": store.name,
            "currentPrice": float(row["search_price"]),
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

        href = link_el.get("href", "")
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

def write_deals(db, deals: list[dict]) -> int:
    """
    Upsert all deals into Firestore /deals using batched writes.

    Mirrors the behaviour of FirestoreDealRepository.upsertDeals() in Flutter —
    `batch.set()` with no merge option overwrites every field atomically, so a
    price change on the next run always wins.
    """
    if not deals:
        return 0

    collection = db.collection("deals")
    now = datetime.now(timezone.utc)
    written = 0

    for i in range(0, len(deals), FIRESTORE_BATCH_SIZE):
        chunk = deals[i : i + FIRESTORE_BATCH_SIZE]
        batch = db.batch()
        for deal in chunk:
            ref = collection.document(deal["id"])
            batch.set(ref, {**deal, "scrapedAt": now})
        batch.commit()
        written += len(chunk)
        log.info("  Committed batch of %d (total so far: %d).", len(chunk), written)

    return written


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
    # ── Firebase Admin SDK init ───────────────────────────────────────────────────
    cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if cred_path:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        log.info("Firebase initialised with service account: %s", cred_path)
    else:
        firebase_admin.initialize_app()
        log.info("Firebase initialised using Application Default Credentials.")

    db = firestore.client()

    # ── Scrape each store independently ──────────────────────────────────────────
    all_deals: list[dict] = []

    for store in STORES:
        try:
            deals = scrape_store(store)
            all_deals.extend(deals)
            log.info("[%s] Collected %d deals.", store.name, len(deals))
        except Exception as exc:
            # Belt-and-suspenders: individual scrapers already isolate network
            # errors, but any unexpected exception here must never abort the
            # remaining stores.
            log.exception(
                "[%s] Unexpected error — store skipped: %s", store.name, exc
            )

    # ── Write to Firestore ────────────────────────────────────────────────────────
    if not all_deals:
        log.warning("No deals collected from any store — Firestore /deals unchanged.")
        return

    log.info("Writing %d total deals to Firestore /deals…", len(all_deals))
    written = write_deals(db, all_deals)
    log.info("Pipeline complete. %d documents written to /deals.", written)


if __name__ == "__main__":
    main()
