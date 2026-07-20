import html
import json
import re
import time

import requests
from firebase_functions import https_fn
from firebase_admin import initialize_app, firestore, messaging, auth

# Initialize the Firebase Admin SDK
initialize_app()

# ─── Brand landing page prerendering ────────────────────────────────────────
#
# This app is a Flutter Web SPA rendered via CanvasKit (paints to a <canvas>
# element, not real DOM text), so search crawlers can't read its content the
# normal way. This function implements "dynamic rendering": Firebase Hosting
# rewrites /brands/** here (see firebase.json); a request from a known bot
# gets real, crawlable static HTML (with actual deal content + JSON-LD)
# rendered server-side, while a real visitor gets passed through to the
# normal Flutter app shell, which then renders BrandLandingPage client-side
# exactly like any other in-app navigation.
#
# Mirrors lib/features/deals/domain/brand_landing.dart — kept in sync
# manually (Python backend and Dart frontend can't share a single source of
# truth here) since it's a small, stable list.
BRAND_PAGES = {
    "dyson-sweden": {"brand": "Dyson", "region": "Sweden", "store": "dyson_se"},
    "dyson-norway": {"brand": "Dyson", "region": "Norway", "store": "dyson_no"},
    "samsung-sweden": {"brand": "Samsung", "region": "Sweden", "store": "samsung_se"},
    "samsung-norway": {"brand": "Samsung", "region": "Norway", "store": "samsung_no"},
    "acer-sweden": {"brand": "Acer", "region": "Sweden", "store": "acer_se"},
    "acer-norway": {"brand": "Acer", "region": "Norway", "store": "acer_no"},
    "sharkninja-sweden": {"brand": "SharkNinja", "region": "Sweden", "store": "sharkninja_se"},
    "sharkninja-norway": {"brand": "SharkNinja", "region": "Norway", "store": "sharkninja_no"},
    "diamond-smile-sweden": {"brand": "Diamond Smile", "region": "Sweden", "store": "diamondsmile_se"},
    "babubas-sweden": {"brand": "Babubas", "region": "Sweden", "store": "babubas_se"},
    "deluxe-home-art-shop-sweden": {"brand": "Deluxe Home Art Shop", "region": "Sweden", "store": "deluxehomeartshop_se"},
    "bazta-sweden": {"brand": "Bazta", "region": "Sweden", "store": "Bazta_se"},
    "perfumeza-sweden": {"brand": "Perfumeza", "region": "Sweden", "store": "perfumeza_se"},
    "plusshop-sweden": {"brand": "PlusShop", "region": "Sweden", "store": "plusshop_se"},
    "byvoks-norway": {"brand": "Byvoks", "region": "Norway", "store": "byvoks_no"},
    # navimow_se deliberately excluded — see the matching comment in
    # lib/features/deals/domain/brand_landing.dart.
}

API_BASE = "https://dealfinder-swr5.onrender.com"
SITE_BASE = "https://prispuls.com"

# `products.feed_region` (== StoreConfig.id in scraper.py, e.g. "dyson_se")
# is the only per-product store identifier the API returns — the actual
# display name (StoreConfig.name, "Dyson Sweden") is computed in scraper.py
# but never persisted. Mirrors lib/features/deals/domain/store_display_names.dart
# — kept in sync manually with STORES in scraper/scraper.py, same as
# BRAND_PAGES above.
STORE_DISPLAY_NAMES = {
    "acer_se": "Acer Sweden",
    "samsung_se": "Samsung Sweden",
    "navimow_se": "Navimow Sweden",
    "diamondsmile_se": "Diamond Smile Sweden",
    "babubas_se": "Babubas Sweden",
    "sharkninja_se": "SharkNinja Sweden",
    "deluxehomeartshop_se": "Deluxe Home Art Shop Sweden",
    "Bazta_se": "Bazta Sweden",
    "perfumeza_se": "Perfumeza Sweden",
    "plusshop_se": "PlusShop Sweden",
    "dyson_se": "Dyson Sweden",
    "dyson_no": "Dyson Norway",
    "sharkninja_no": "SharkNinja Norway",
    "acer_no": "Acer Norway",
    "byvoks_no": "Byvoks Norway",
    "samsung_no": "Samsung Norway",
}


def _store_display_name(feed_region: str) -> str:
    known = STORE_DISPLAY_NAMES.get(feed_region)
    if known:
        return known
    without_suffix = re.sub(r"_(se|no)$", "", feed_region, flags=re.IGNORECASE)
    words = [w for w in re.split(r"[_-]", without_suffix) if w]
    return " ".join(w[:1].upper() + w[1:] for w in words) if words else feed_region

_BOT_UA_RE = re.compile(
    r"(googlebot|bingbot|yandex|baiduspider|duckduckbot|slurp|"
    r"facebookexternalhit|facebookcatalog|twitterbot|linkedinbot|"
    r"discordbot|telegrambot|whatsapp|applebot|slackbot|"
    r"semrushbot|ahrefsbot|pinterest)",
    re.IGNORECASE,
)

# Cached across warm invocations of the same function instance — avoids
# re-fetching the (large, rarely-changing) Flutter app shell on every human
# request to a /brands/* URL. 10 minutes comfortably covers "a deploy just
# went out" without ever serving something too stale.
_index_html_cache: dict[str, object] = {"html": None, "fetched_at": 0.0}
_INDEX_CACHE_TTL_SECONDS = 600


def _fetch_index_html() -> str:
    cached = _index_html_cache["html"]
    age = time.time() - _index_html_cache["fetched_at"]
    if cached and age < _INDEX_CACHE_TTL_SECONDS:
        return cached
    resp = requests.get(f"{SITE_BASE}/index.html", timeout=8)
    resp.raise_for_status()
    _index_html_cache["html"] = resp.text
    _index_html_cache["fetched_at"] = time.time()
    return resp.text


def _fetch_brand_deals(store: str) -> list[dict]:
    resp = requests.get(
        f"{API_BASE}/api/deals/by-store",
        params={"store": store, "limit": 24},
        timeout=8,
    )
    resp.raise_for_status()
    return resp.json().get("items", [])


def _render_brand_html(slug: str, page: dict, deals: list[dict]) -> str:
    brand, region = page["brand"], page["region"]
    title = f"Best Deals on {brand} in {region} | PrisPuls"
    description = (
        f"Compare live prices on {brand} products in {region}. "
        f"PrisPuls tracks {len(deals)} {brand} deals across retailers so you "
        f"always see the best price first."
        if deals
        else f"PrisPuls tracks {brand} prices in {region} across retailers."
    )
    canonical = f"{SITE_BASE}/brands/{slug}"

    list_items_html = []
    structured_items = []
    for i, d in enumerate(deals, start=1):
        product_title = html.escape(d.get("title") or brand)
        price = d.get("price")
        currency = html.escape(d.get("currency") or "")
        url = html.escape(d.get("tracking_url") or canonical, quote=True)
        image = d.get("image_url")
        price_text = f"{price:.0f} {currency}" if price else ""
        list_items_html.append(
            f'<li><a href="{url}" rel="nofollow sponsored">{product_title}</a>'
            + (f" — {html.escape(price_text)}" if price_text else "")
            + "</li>"
        )
        structured_items.append(
            {
                "@type": "ListItem",
                "position": i,
                "item": {
                    "@type": "Product",
                    "name": d.get("title") or brand,
                    "image": image,
                    "url": d.get("tracking_url"),
                    "offers": {
                        "@type": "Offer",
                        "price": price,
                        "priceCurrency": currency,
                        "url": d.get("tracking_url"),
                    },
                },
            }
        )

    structured_data = json.dumps(
        {
            "@context": "https://schema.org",
            "@type": "ItemList",
            "name": title,
            "description": description,
            "itemListElement": structured_items,
        }
    # Defends against a scraped title/URL that happens to contain a literal
    # "</script>", which would otherwise break out of the script tag below.
    ).replace("</script>", "<\\/script>")

    deals_html = (
        "<ul>" + "".join(list_items_html) + "</ul>"
        if deals
        else "<p>No live deals right now — check back soon.</p>"
    )

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>{html.escape(title)}</title>
<meta name="description" content="{html.escape(description)}">
<link rel="canonical" href="{canonical}">
<meta property="og:type" content="website">
<meta property="og:url" content="{canonical}">
<meta property="og:title" content="{html.escape(title)}">
<meta property="og:description" content="{html.escape(description)}">
<script type="application/ld+json">{structured_data}</script>
</head>
<body>
<h1>{html.escape(title)}</h1>
<p>{html.escape(description)}</p>
{deals_html}
<p><a href="{SITE_BASE}/">Browse all deals on PrisPuls</a></p>
</body>
</html>"""


@https_fn.on_request(region="europe-north1")
def prerender_brand_page(req: https_fn.Request) -> https_fn.Response:
    """Firebase Hosting rewrites /brands/** here (see firebase.json). Real
    visitors get passed through to the normal Flutter app shell; known
    search/social crawlers get a real static HTML snapshot with actual deal
    content, since the Flutter app itself renders via CanvasKit (a canvas,
    not crawlable DOM text) and can't be indexed directly.
    """
    slug = req.path.rstrip("/").rsplit("/", 1)[-1]
    page = BRAND_PAGES.get(slug)

    if page is None:
        return https_fn.Response("Not found", status=404)

    user_agent = req.headers.get("User-Agent", "")
    if not _BOT_UA_RE.search(user_agent):
        try:
            return https_fn.Response(_fetch_index_html(), content_type="text/html")
        except requests.RequestException:
            # Fall back to a redirect to the app root rather than a hard
            # error — worse UX (loses the deep link) but never a dead end.
            return https_fn.Response(
                "", status=302, headers={"Location": SITE_BASE + "/"}
            )

    try:
        deals = _fetch_brand_deals(page["store"])
    except requests.RequestException:
        deals = []

    return https_fn.Response(
        _render_brand_html(slug, page, deals), content_type="text/html"
    )

def _fetch_product(product_id: str) -> dict | None:
    resp = requests.get(
        f"{API_BASE}/api/products", params={"ids": product_id}, timeout=8
    )
    resp.raise_for_status()
    items = resp.json()
    return items[0] if items else None


def _render_product_html(product: dict) -> str:
    """Keep this copy formula in sync with DealDetailsPage._syncProductMeta
    in Dart (lib/features/deals/presentation/deal_details_page.dart) — same
    locale-by-currency logic, same canonical URL shape, same Product
    JSON-LD — so a crawler's static snapshot and a real visitor's
    client-rendered page describe the same product identically.
    """
    product_id = product.get("product_id", "")
    title_text = product.get("title") or "Deal"
    source = _store_display_name(product.get("feed_region") or "Unknown")
    price = product.get("price")
    currency = (product.get("currency") or "SEK").upper()
    tracking_url = product.get("tracking_url") or f"{SITE_BASE}/"
    image = product.get("image_url")
    retail_price = product.get("retail_price")

    is_norwegian = currency == "NOK"
    price_text = f"{price:.0f}" if isinstance(price, (int, float)) else ""
    title = (
        f"{title_text} – {price_text} {currency} | PrisPuls"
        if price_text
        else f"{title_text} | PrisPuls"
    )

    if is_norwegian:
        description = (
            f"Sammenlign prisen på {title_text} hos {source} og andre "
            f"nettbutikker. PrisPuls sporer prishistorikken slik at du "
            f"alltid vet om dette faktisk er et godt tilbud."
        )
    else:
        description = (
            f"Jämför priset på {title_text} hos {source} och andra "
            f"nätbutiker. PrisPuls spårar prishistoriken så du alltid vet "
            f"om det här verkligen är ett bra pris."
        )

    canonical = f"{SITE_BASE}/products/{product_id}"

    structured_data = json.dumps(
        {
            "@context": "https://schema.org",
            "@type": "Product",
            "name": title_text,
            **({"image": [image]} if image else {}),
            "brand": {"@type": "Brand", "name": source},
            "offers": {
                "@type": "Offer",
                "url": tracking_url,
                "priceCurrency": currency,
                "price": price_text or "0",
                "availability": "https://schema.org/InStock",
                "seller": {"@type": "Organization", "name": source},
            },
        }
    # Defends against a scraped title/URL that happens to contain a literal
    # "</script>", which would otherwise break out of the script tag below.
    ).replace("</script>", "<\\/script>")

    original_price_html = (
        f"<p><s>{retail_price:.0f} {html.escape(currency)}</s></p>"
        if isinstance(retail_price, (int, float)) and retail_price > (price or 0)
        else ""
    )

    return f"""<!DOCTYPE html>
<html lang="{'nb' if is_norwegian else 'sv'}">
<head>
<meta charset="UTF-8">
<title>{html.escape(title)}</title>
<meta name="description" content="{html.escape(description)}">
<link rel="canonical" href="{canonical}">
<link rel="alternate" hreflang="sv-SE" href="{canonical}">
<link rel="alternate" hreflang="nb-NO" href="{canonical}">
<link rel="alternate" hreflang="x-default" href="{canonical}">
<meta property="og:type" content="product">
<meta property="og:url" content="{canonical}">
<meta property="og:title" content="{html.escape(title)}">
<meta property="og:description" content="{html.escape(description)}">
<meta property="product:price:amount" content="{price_text or '0'}">
<meta property="product:price:currency" content="{html.escape(currency)}">
<script type="application/ld+json">{structured_data}</script>
</head>
<body>
<h1>{html.escape(title_text)}</h1>
<p>{html.escape(description)}</p>
<p>{price_text} {html.escape(currency)}</p>
{original_price_html}
<p><a href="{html.escape(tracking_url, quote=True)}" rel="nofollow sponsored">View deal at {html.escape(source)}</a></p>
<p><a href="{SITE_BASE}/">Browse all deals on PrisPuls</a></p>
</body>
</html>"""


@https_fn.on_request(region="europe-north1")
def prerender_product_page(req: https_fn.Request) -> https_fn.Response:
    """Firebase Hosting rewrites /products/** here (see firebase.json) —
    same dynamic-rendering pattern as prerender_brand_page (see its
    docstring), for individual product pages instead of per-brand catalogs.
    """
    product_id = req.path.rstrip("/").rsplit("/", 1)[-1]

    user_agent = req.headers.get("User-Agent", "")
    if not _BOT_UA_RE.search(user_agent):
        try:
            return https_fn.Response(_fetch_index_html(), content_type="text/html")
        except requests.RequestException:
            return https_fn.Response(
                "", status=302, headers={"Location": SITE_BASE + "/"}
            )

    try:
        product = _fetch_product(product_id)
    except requests.RequestException:
        product = None

    if product is None:
        return https_fn.Response("Not found", status=404)

    return https_fn.Response(
        _render_product_html(product), content_type="text/html"
    )


# The build-time web/sitemap.xml only ever listed the homepage + the 15
# brand landing pages — zero individual product URLs, despite
# prerender_product_page above already giving every /products/{id} page
# real, crawlable, structured-data-bearing HTML. Google has no way to
# *discover* those URLs on its own (this is a CanvasKit SPA — there are no
# real <a href> elements for a crawler to follow), so with a static
# 16-entry sitemap the entire product catalog was effectively invisible to
# search, no matter how good the per-page SEO was. This serves a live
# sitemap instead, seeded from the same "Best Deals" ordering the homepage
# uses (already diverse across stores — see get_products in api.py), so it
# grows and refreshes automatically as the catalog does.
_sitemap_cache: dict[str, object] = {"xml": None, "fetched_at": 0.0}
_SITEMAP_CACHE_TTL_SECONDS = 3600
_SITEMAP_PRODUCT_PAGES = 5  # 5 x 200 = up to 1000 product URLs.


def _sitemap_url_entry(loc: str, changefreq: str, priority: str) -> str:
    return (
        f"<url><loc>{html.escape(loc)}</loc>"
        f"<changefreq>{changefreq}</changefreq><priority>{priority}</priority></url>"
    )


def _build_sitemap_xml() -> str:
    entries = [_sitemap_url_entry(f"{SITE_BASE}/", "hourly", "1.0")]
    for slug in BRAND_PAGES:
        entries.append(
            _sitemap_url_entry(f"{SITE_BASE}/brands/{slug}", "daily", "0.8")
        )

    seen_ids: set[str] = set()
    for page in range(1, _SITEMAP_PRODUCT_PAGES + 1):
        try:
            resp = requests.get(
                f"{API_BASE}/api/products",
                params={"page": page, "limit": 200},
                timeout=8,
            )
            resp.raise_for_status()
            items = resp.json().get("items", [])
        except requests.RequestException:
            break
        if not items:
            break
        for item in items:
            product_id = item.get("product_id")
            if not product_id or product_id in seen_ids:
                continue
            seen_ids.add(product_id)
            entries.append(
                _sitemap_url_entry(
                    f"{SITE_BASE}/products/{product_id}", "daily", "0.6"
                )
            )

    return (
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
        + "".join(entries)
        + "</urlset>"
    )


@https_fn.on_request(region="europe-north1")
def sitemap_xml(req: https_fn.Request) -> https_fn.Response:
    """Firebase Hosting rewrites /sitemap.xml here (see firebase.json)."""
    cached = _sitemap_cache["xml"]
    age = time.time() - _sitemap_cache["fetched_at"]
    if cached and age < _SITEMAP_CACHE_TTL_SECONDS:
        return https_fn.Response(cached, content_type="application/xml")

    try:
        xml = _build_sitemap_xml()
    except requests.RequestException:
        if cached:
            return https_fn.Response(cached, content_type="application/xml")
        return https_fn.Response("Sitemap temporarily unavailable", status=503)

    _sitemap_cache["xml"] = xml
    _sitemap_cache["fetched_at"] = time.time()
    return https_fn.Response(xml, content_type="application/xml")


@https_fn.on_call(region="europe-north1")
def send_price_alert(req: https_fn.CallableRequest) -> any:
    """
    A callable HTTP function that sends a push notification to a specific user.
    Expected payload: {"user_id": "123...", "title": "Price Drop!", "body": "..."}
    """
    data = req.data
    user_id = data.get("user_id") if isinstance(data, dict) else None
    title = data.get("title", "Price Drop Alert! 🎉") if isinstance(data, dict) else "Price Drop Alert! 🎉"
    body = data.get("body", "A product you are watching just dropped in price.") if isinstance(data, dict) else "A product you are watching just dropped in price."
    product_url = data.get("product_url", "alerts_page") if isinstance(data, dict) else "alerts_page"

    if not user_id:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="The 'user_id' parameter is required."
        )

    if req.auth is None or not req.auth.uid:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="User must be authenticated to send an alert."
        )

    if req.auth.uid != user_id:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.PERMISSION_DENIED,
            message="Cannot send an alert to a different user."
        )

    db = firestore.client()
    user_ref = db.collection("users").document(user_id)
    user_doc = user_ref.get()

    if not user_doc.exists:
        return {"success": False, "error": "User not found."}

    user_data = user_doc.to_dict()
    tokens = user_data.get("fcmTokens", [])

    if not tokens:
        return {"success": False, "message": "No FCM tokens found for this user."}

    # Construct the multicast message for all of the user's devices
    message = messaging.MulticastMessage(
        notification=messaging.Notification(title=title, body=body),
        data={"product_url": str(product_url)},
        tokens=tokens,
    )

    # Send the message
    response = messaging.send_each_multicast(message)
    
    # Clean up any tokens that failed (e.g., user uninstalled the app)
    if response.failure_count > 0:
        failed_tokens = [tokens[i] for i, resp in enumerate(response.responses) if not resp.success]
        # Remove the invalid tokens from Firestore
        user_ref.update({"fcmTokens": firestore.ArrayRemove(failed_tokens)})

    return {"success": True, "sent_count": response.success_count}

@https_fn.on_call(region="europe-north1")
def delete_account(req: https_fn.CallableRequest) -> any:
    """
    Deletes the authenticated user's Firestore data and their Firebase Auth account.
    """
    # 1. Ensure the user is actually logged in and making the request
    if req.auth is None or not req.auth.uid:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="User must be authenticated to delete."
        )

    uid = req.auth.uid
    db = firestore.client()

    # 2. Delete the user's alert configs (subcollections must be deleted manually)
    configs_ref = db.collection("users").document(uid).collection("alert_configs")
    for doc in configs_ref.stream():
        doc.reference.delete()
        
    # 3. Delete the user's main document
    db.collection("users").document(uid).delete()
    
    # 4. Delete the user from Firebase Auth
    auth.delete_user(uid)

    print(f"Successfully deleted account and data for UID: {uid}")
    return {"success": True}