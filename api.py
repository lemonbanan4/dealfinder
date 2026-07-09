import datetime
import ipaddress
import logging
import math
import os
from contextlib import contextmanager

import psycopg2
import psycopg2.pool
import requests
from psycopg2.extras import RealDictCursor
from fastapi import FastAPI, Header, HTTPException, Query, Request
from fastapi.middleware.cors import CORSMiddleware
from google.auth.transport import requests as google_auth_requests
from google.oauth2 import id_token as google_id_token
from pydantic import BaseModel
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("prispuls-api")

# Get connection string from environment
DATABASE_URL = os.environ.get("DATABASE_URL")

# The Firebase project this app's users sign in to — ID tokens are only
# accepted if they were issued for this project (checked as the JWT audience).
FIREBASE_PROJECT_ID = "dealfinderpro-bc5be"
_google_auth_request = google_auth_requests.Request()

# Used by /api/exchange-rates — kept server-side only. Previously this key
# was hardcoded directly in the Flutter client (currency_provider.dart),
# trivially extractable from the compiled web bundle on a public site.
EXCHANGE_RATE_API_KEY = os.environ.get("EXCHANGE_RATE_API_KEY")

_GENERIC_ERROR = "Internal server error. Please try again later."

def _client_ip(request: Request) -> str:
    # Render (and most PaaS proxies) put the real client IP first in
    # X-Forwarded-For; request.client.host would otherwise just be the proxy.
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else ""


app = FastAPI(title="Prispuls Product Engine")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://prispuls.com",
        "https://www.prispuls.com",
        "https://dealfinderpro-bc5be.web.app",
        "https://dealfinderpro-bc5be.firebaseapp.com",
    ],
    allow_origin_regex=r"https?://localhost(:\d+)?|https?://127\.0\.0\.1(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Per-IP rate limiting on the public, unauthenticated endpoints
# (/api/products, /api/deals/biggest-drops, /api/stats, /api/geo-region,
# /api/exchange-rates) — previously nothing stood between a scripted caller
# and unlimited requests, each of which (pre-pooling) opened its own DB
# connection. Limits below are deliberately generous — well above anything
# a real browser session would trigger — so they only ever throttle abuse,
# not normal use.
limiter = Limiter(key_func=_client_ip)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# A pooled connection is borrowed per-request and returned when the request
# finishes, instead of opening a brand-new Postgres connection on every
# single request (including the public, unauthenticated, likely-highest-
# traffic endpoints below) — the previous pattern risked exhausting
# Supabase's connection cap under any real concurrent load, which would
# fail every endpoint at once, not just the one under load.
# maxconn is intentionally conservative — this only needs to comfortably
# cover concurrent requests to *this* service, well under Supabase's own
# connection limit (shared with the scraper and any other client).
#
# Created lazily (on first request) rather than at import time: eagerly
# connecting at module load would mean a transient DB/DATABASE_URL problem
# takes down the entire process before it can even start serving the
# DB-independent endpoints (/, /api/geo-region, /api/exchange-rates)
# instead of just failing the DB-touching ones, which is how this behaved
# before pooling.
_connection_pool: psycopg2.pool.ThreadedConnectionPool | None = None


def _get_pool() -> psycopg2.pool.ThreadedConnectionPool:
    global _connection_pool
    if _connection_pool is None:
        _connection_pool = psycopg2.pool.ThreadedConnectionPool(
            minconn=1, maxconn=10, dsn=DATABASE_URL, sslmode="require",
        )
    return _connection_pool


@contextmanager
def db_cursor(dict_cursor: bool = False):
    """Borrows a pooled connection + cursor for the duration of the `with`
    block. On success, callers are responsible for calling conn.commit()
    themselves (mirroring the previous explicit-commit pattern); on any
    exception the connection is rolled back before being returned to the
    pool, so a failed transaction on one request can't leak into whatever
    unrelated request borrows that same connection next.
    """
    pool = _get_pool()
    conn = pool.getconn()
    cursor = None
    try:
        cursor = conn.cursor(cursor_factory=RealDictCursor if dict_cursor else None)
        yield conn, cursor
    except Exception:
        conn.rollback()
        raise
    finally:
        if cursor:
            cursor.close()
        pool.putconn(conn)


def verify_firebase_token(authorization: str | None) -> dict:
    """Verifies a Firebase ID token sent as an 'Authorization: Bearer <token>'
    header and returns its decoded claims (includes 'sub' as the Firebase
    uid, 'email', 'email_verified'). This only checks the token's signature
    against Google's public keys and its audience/issuer — no service
    account credential is needed, unlike the full firebase-admin SDK.
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token.")
    token = authorization[len("Bearer "):]
    try:
        return google_id_token.verify_firebase_token(
            token, _google_auth_request, audience=FIREBASE_PROJECT_ID
        )
    except ValueError as e:
        raise HTTPException(status_code=401, detail=f"Invalid auth token: {e}")


class CreateAlertRequest(BaseModel):
    product_id: str
    product_title: str
    target_price: float
    region: str


class UpdateAlertRequest(BaseModel):
    target_price: float


@app.post("/api/alerts")
def create_alert(body: CreateAlertRequest, authorization: str = Header(None)):
    claims = verify_firebase_token(authorization)
    if not claims.get("email_verified", False):
        raise HTTPException(status_code=403, detail="Please verify your email to set price alerts.")
    uid = claims["sub"]
    email = claims.get("email")

    try:
        with db_cursor() as (conn, cursor):
            # This table has no known unique constraint on (product_id,
            # user_id) to rely on an upsert for, so replace any existing row
            # explicitly — matches the app's 1-alert-per-product-per-user
            # model.
            cursor.execute(
                "DELETE FROM price_alerts WHERE product_id = %s AND user_id = %s",
                (body.product_id, uid),
            )
            cursor.execute(
                """
                INSERT INTO price_alerts
                    (product_id, user_id, user_email, target_price, product_title, currency, region, is_active, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, true, %s)
                """,
                (
                    body.product_id,
                    uid,
                    email,
                    body.target_price,
                    body.product_title,
                    "SEK",  # every product this app tracks is priced in SEK
                    body.region,
                    datetime.datetime.now(datetime.timezone.utc).isoformat(),
                ),
            )
            conn.commit()
            return {"status": "ok"}
    except Exception:
        log.exception("create_alert failed for uid=%s product_id=%s", uid, body.product_id)
        raise HTTPException(status_code=500, detail=_GENERIC_ERROR)


@app.patch("/api/alerts/{product_id}")
def update_alert(product_id: str, body: UpdateAlertRequest, authorization: str = Header(None)):
    claims = verify_firebase_token(authorization)
    uid = claims["sub"]

    try:
        with db_cursor() as (conn, cursor):
            # Also re-arm the alert (is_active=true): editing implies the
            # user wants to be notified again. Without this, an alert that
            # already fired once (is_active flipped false by the scraper)
            # would accept the new target price but never actually fire
            # again, since the scraper only ever checks rows where
            # is_active=true.
            cursor.execute(
                "UPDATE price_alerts SET target_price = %s, is_active = true WHERE product_id = %s AND user_id = %s",
                (body.target_price, product_id, uid),
            )
            conn.commit()
            return {"status": "ok"}
    except Exception:
        log.exception("update_alert failed for uid=%s product_id=%s", uid, product_id)
        raise HTTPException(status_code=500, detail=_GENERIC_ERROR)


@app.delete("/api/alerts/{product_id}")
def delete_alert(product_id: str, authorization: str = Header(None)):
    claims = verify_firebase_token(authorization)
    uid = claims["sub"]

    try:
        with db_cursor() as (conn, cursor):
            cursor.execute(
                "DELETE FROM price_alerts WHERE product_id = %s AND user_id = %s",
                (product_id, uid),
            )
            conn.commit()
            return {"status": "ok"}
    except Exception:
        log.exception("delete_alert failed for uid=%s product_id=%s", uid, product_id)
        raise HTTPException(status_code=500, detail=_GENERIC_ERROR)


@app.get("/api/alerts/fired")
def get_fired_alerts(authorization: str = Header(None)):
    """Alerts belonging to the caller that scraper.py's price check has
    already flipped to is_active=false — used to drive the "an alert just
    triggered" indicator in the app without exposing other users' rows.
    """
    claims = verify_firebase_token(authorization)
    uid = claims["sub"]

    try:
        with db_cursor(dict_cursor=True) as (conn, cursor):
            cursor.execute(
                """
                SELECT id, product_id, product_title, target_price
                FROM price_alerts
                WHERE user_id = %s AND is_active = false
                """,
                (uid,),
            )
            return {"items": cursor.fetchall()}
    except Exception:
        log.exception("get_fired_alerts failed for uid=%s", uid)
        raise HTTPException(status_code=500, detail=_GENERIC_ERROR)

@app.get("/")
def read_root():
    # Deliberately DB-independent — this is the process-liveness check
    # (whatever Render currently polls at "/"). Use /api/health below for a
    # real readiness check that verifies the DB is actually reachable.
    return {"message": "API is alive!"}


@app.get("/api/health")
def health_check():
    """DB-aware readiness check — GET / only confirms the process is up,
    which would still report "healthy" during a full DB outage (e.g. the
    connection-pool/Supabase-limit exhaustion scenario this API is
    vulnerable to). Point Render's health check at this path instead of "/"
    if you want an outage to actually surface as unhealthy.
    """
    try:
        with db_cursor() as (conn, cursor):
            cursor.execute("SELECT 1")
        return {"status": "ok", "database": "reachable"}
    except Exception as e:
        log.exception("Health check DB probe failed")
        raise HTTPException(status_code=503, detail=f"Database unreachable: {type(e).__name__}")


# In-memory per-IP cache — geolocation is a best-effort default-region guess,
# not something that needs to survive a restart, so a plain dict (no TTL) is
# fine at this traffic scale and avoids hitting the geo-IP service on every
# single page load from the same visitor.
_geo_region_cache: dict[str, str] = {}


@app.get("/api/geo-region")
@limiter.limit("20/minute")
def get_geo_region(request: Request):
    """Best-effort 'se'/'no' region guess from the caller's IP — lets the
    client set a sensible default region without relying solely on browser
    language, which can easily be wrong (e.g. an English-language browser
    physically in Norway would otherwise default to Sweden). Returns
    {"region": null} whenever a confident guess isn't available; the client
    is expected to keep its own locale-based guess in that case.
    """
    ip = _client_ip(request)

    try:
        if not ip or ipaddress.ip_address(ip).is_private:
            return {"region": None}
    except ValueError:
        return {"region": None}

    if ip in _geo_region_cache:
        return {"region": _geo_region_cache[ip]}

    region = None
    try:
        resp = requests.get(
            f"http://ip-api.com/json/{ip}",
            params={"fields": "status,countryCode"},
            timeout=3,
        )
        data = resp.json()
        if data.get("status") == "success":
            region = "no" if data.get("countryCode") == "NO" else "se"
    except Exception:
        region = None

    if region:
        _geo_region_cache[ip] = region
    return {"region": region}

# Whitelisted sort options for /api/products — the query param is only ever
# used as a dict key here, never interpolated directly into SQL, so an
# unrecognized/malicious value just falls through to the default order below
# rather than reaching the query string.
_SORT_ORDER_CLAUSES = {
    "price_asc": "price ASC",
    "price_desc": "price DESC",
    "newest": "last_updated DESC",
}


@app.get("/api/products")
@limiter.limit("60/minute")
def get_products(
    request: Request,
    region: str = Query(None, description="Region to filter"),
    page: int = Query(None, ge=1, description="1-indexed page number; omit for the legacy unpaginated response"),
    limit: int = Query(24, ge=1, le=200, description="Items per page"),
    sort: str = Query(None, description="price_asc | price_desc | newest; omit for the default best-deals order"),
    ids: str = Query(None, description="Comma-separated product_ids; when set, returns just those products (ignores region/page/sort)"),
):
    try:
        with db_cursor(dict_cursor=True) as (conn, cursor):
            if ids is not None:
                id_list = [i.strip() for i in ids.split(",") if i.strip()][:50]
                if not id_list:
                    return []
                cursor.execute(
                    "SELECT * FROM products WHERE product_id = ANY(%s) AND price > 0",
                    (id_list,),
                )
                return cursor.fetchall()

            # Base query
            query = "SELECT * FROM products"
            params = []

            # price > 0 excludes gift-card/free-item rows (e.g. "Presentkort")
            # that the Awin feed sometimes includes with a literal 0 price —
            # without this they sort to the very top of every "biggest
            # discount" ordering as a permanent, fake "100% off" deal, and to
            # the top of "Price: Low to High" too.
            conditions = ["price > 0"]

            # Filter by region if requested (matches "all_se" or "all_no")
            if region:
                conditions.append("feed_region LIKE %s")
                params.append(f"%{region.lower()}%")

            where_clause = " WHERE " + " AND ".join(conditions)

            if sort in _SORT_ORDER_CLAUSES:
                order_clause = f" ORDER BY {_SORT_ORDER_CLAUSES[sort]}"
            else:
                # Default: biggest percentage discounts first, then newest items
                order_clause = """
                    ORDER BY
                    CASE
                        WHEN retail_price > price THEN (retail_price - price) / retail_price
                        ELSE 0
                    END DESC,
                    last_updated DESC
                """

            if page is None:
                # Legacy shape (bare array): still used by features that need
                # full-catalog visibility client-side (category/search
                # filtering, the "Insane Deals" ribbon, Recently Viewed).
                cursor.execute(query + where_clause + order_clause, params)
                return cursor.fetchall()

            cursor.execute("SELECT COUNT(*) AS count FROM products" + where_clause, params)
            total_count = cursor.fetchone()["count"]

            paged_query = query + where_clause + order_clause + " LIMIT %s OFFSET %s"
            cursor.execute(paged_query, params + [limit, (page - 1) * limit])
            rows = cursor.fetchall()

            return {
                "items": rows,
                "total_count": total_count,
                "page": page,
                "limit": limit,
                "total_pages": max(1, math.ceil(total_count / limit)),
            }
    except Exception:
        log.exception("get_products failed (region=%s page=%s sort=%s)", region, page, sort)
        raise HTTPException(status_code=500, detail=_GENERIC_ERROR)


def _region_filter(region: str | None, params: list) -> str:
    if not region:
        return ""
    params.append(f"%{region.lower()}%")
    return " AND p.feed_region LIKE %s"


@app.get("/api/deals/biggest-drops")
@limiter.limit("30/minute")
def get_biggest_drops(
    request: Request,
    region: str = Query(None, description="Region to filter"),
    limit: int = Query(3, ge=1, le=20),
):
    """Products whose price has dropped versus a price_history snapshot from
    >=24h ago, biggest drop first. The historical price is returned under
    the `retail_price` key — the same key /api/products uses for a product's
    list price — purely so the existing Deal.fromJson parsing and DealCard's
    discount-badge/strikethrough rendering can be reused as-is on the client;
    this never touches the real products.retail_price column.
    """
    try:
        with db_cursor(dict_cursor=True) as (conn, cursor):
            params: list = []
            where_region = _region_filter(region, params)

            query = f"""
                SELECT
                    p.product_id,
                    p.feed_region,
                    p.title,
                    p.price,
                    ph.price AS retail_price,
                    p.tracking_url,
                    p.image_url,
                    p.currency,
                    p.last_updated
                FROM products p
                JOIN LATERAL (
                    SELECT price
                    FROM price_history
                    WHERE product_id = p.product_id
                      AND recorded_at <= now() - interval '24 hours'
                    ORDER BY recorded_at DESC
                    LIMIT 1
                ) ph ON true
                WHERE ph.price > p.price AND p.price > 0
                {where_region}
                ORDER BY ((ph.price - p.price) / ph.price) DESC
                LIMIT %s
            """
            params.append(limit)
            cursor.execute(query, params)
            return {"items": cursor.fetchall()}
    except Exception:
        log.exception("get_biggest_drops failed (region=%s)", region)
        raise HTTPException(status_code=500, detail=_GENERIC_ERROR)


@app.get("/api/deals/top-discounts")
@limiter.limit("30/minute")
def get_top_discounts(
    request: Request,
    region: str = Query(None, description="Region to filter"),
    min_discount: float = Query(25, ge=0, le=100, description="Minimum % off a product's own retail_price"),
    limit: int = Query(100, ge=1, le=200),
):
    """Products discounted >= min_discount% off their own listed retail_price,
    biggest discount first — backs the "Insane Deals" shelf. Unlike
    /api/deals/biggest-drops (a real price_history-based drop over time),
    this compares a product's own retail_price column vs its current price.
    """
    try:
        with db_cursor(dict_cursor=True) as (conn, cursor):
            threshold = min_discount / 100.0
            params: list = [threshold]
            where_region = _region_filter(region, params)
            query = f"""
                SELECT p.*
                FROM products p
                WHERE p.price > 0
                  AND p.retail_price > p.price
                  AND (p.retail_price - p.price) / p.retail_price >= %s
                {where_region}
                ORDER BY (p.retail_price - p.price) / p.retail_price DESC
                LIMIT %s
            """
            params.append(limit)
            cursor.execute(query, params)
            return {"items": cursor.fetchall()}
    except Exception:
        log.exception("get_top_discounts failed (region=%s)", region)
        raise HTTPException(status_code=500, detail=_GENERIC_ERROR)


@app.get("/api/stats")
@limiter.limit("30/minute")
def get_stats(request: Request, region: str = Query(None, description="Region to filter")):
    """Aggregate counts driving the feed's live-status banner."""
    try:
        with db_cursor(dict_cursor=True) as (conn, cursor):
            drop_params: list = []
            where_region = _region_filter(region, drop_params)
            cursor.execute(
                f"""
                SELECT COUNT(*) AS count
                FROM products p
                JOIN LATERAL (
                    SELECT price
                    FROM price_history
                    WHERE product_id = p.product_id
                      AND recorded_at <= now() - interval '24 hours'
                    ORDER BY recorded_at DESC
                    LIMIT 1
                ) ph ON true
                WHERE ph.price > p.price AND p.price > 0
                {where_region}
                """,
                drop_params,
            )
            price_drops_today = cursor.fetchone()["count"]

            sync_params: list = []
            where_region = _region_filter(region, sync_params)
            cursor.execute(
                f"""
                SELECT COUNT(*) AS count
                FROM products p
                WHERE p.last_updated >= now() - interval '6 hours'
                {where_region}
                """,
                sync_params,
            )
            updated_last_sync = cursor.fetchone()["count"]

            return {
                "price_drops_today": price_drops_today,
                "updated_last_sync": updated_last_sync,
            }
    except Exception:
        log.exception("get_stats failed (region=%s)", region)
        raise HTTPException(status_code=500, detail=_GENERIC_ERROR)


# In-memory cache — exchangerate-api.com's free tier is capped at a modest
# number of calls/month, and rates only meaningfully change a few times a
# day, so refetching more than every 12h would be pure waste.
_exchange_rates_cache: dict = {"data": None, "fetched_at": None}


@app.get("/api/exchange-rates")
@limiter.limit("20/minute")
def get_exchange_rates(request: Request):
    """Proxies exchangerate-api.com so its API key lives only in this
    server's environment — previously the key was hardcoded directly in the
    Flutter client (currency_provider.dart), trivially readable by anyone
    via browser devtools on a public web app. Response shape is passed
    through unchanged (`result`, `base_code`, `conversion_rates`, ...) so the
    client's existing parsing needs no changes beyond the URL it calls.
    """
    cached = _exchange_rates_cache["data"]
    fetched_at = _exchange_rates_cache["fetched_at"]
    if (
        cached
        and fetched_at
        and (datetime.datetime.now(datetime.timezone.utc) - fetched_at).total_seconds() < 12 * 3600
    ):
        return cached

    if not EXCHANGE_RATE_API_KEY:
        if cached:
            return cached
        raise HTTPException(status_code=503, detail="Exchange rate service not configured.")

    try:
        resp = requests.get(
            f"https://v6.exchangerate-api.com/v6/{EXCHANGE_RATE_API_KEY}/latest/SEK",
            timeout=5,
        )
        data = resp.json()
    except Exception:
        log.exception("Failed to fetch exchange rates")
        if cached:
            return cached
        raise HTTPException(status_code=502, detail="Exchange rate service unavailable.")

    if data.get("result") != "success":
        log.error("Exchange rate API returned non-success: %s", data)
        if cached:
            return cached
        raise HTTPException(status_code=502, detail="Exchange rate service error.")

    _exchange_rates_cache["data"] = data
    _exchange_rates_cache["fetched_at"] = datetime.datetime.now(datetime.timezone.utc)
    return data


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)