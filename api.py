import datetime
import math
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import FastAPI, Header, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from google.auth.transport import requests as google_auth_requests
from google.oauth2 import id_token as google_id_token
from pydantic import BaseModel

# Get connection string from environment
DATABASE_URL = os.environ.get("DATABASE_URL")

# The Firebase project this app's users sign in to — ID tokens are only
# accepted if they were issued for this project (checked as the JWT audience).
FIREBASE_PROJECT_ID = "dealfinderpro-bc5be"
_google_auth_request = google_auth_requests.Request()

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

def get_db_connection():
    # sslmode=require is required by Supabase
    return psycopg2.connect(DATABASE_URL, sslmode='require')


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
    product_url: str
    target_price: float


class UpdateAlertRequest(BaseModel):
    target_price: float


@app.post("/api/alerts")
def create_alert(body: CreateAlertRequest, authorization: str = Header(None)):
    claims = verify_firebase_token(authorization)
    if not claims.get("email_verified", False):
        raise HTTPException(status_code=403, detail="Please verify your email to set price alerts.")
    uid = claims["sub"]
    email = claims.get("email")

    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # This table has no known unique constraint on (product_id, user_id)
        # to rely on an upsert for, so replace any existing row explicitly —
        # matches the app's 1-alert-per-product-per-user model.
        cursor.execute(
            "DELETE FROM price_alerts WHERE product_id = %s AND user_id = %s",
            (body.product_id, uid),
        )
        cursor.execute(
            """
            INSERT INTO price_alerts
                (product_id, user_id, user_email, target_price, product_title, product_url, is_active, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, true, %s)
            """,
            (
                body.product_id,
                uid,
                email,
                body.target_price,
                body.product_title,
                body.product_url,
                datetime.datetime.now(datetime.timezone.utc).isoformat(),
            ),
        )
        conn.commit()
        return {"status": "ok"}
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


@app.patch("/api/alerts/{product_id}")
def update_alert(product_id: str, body: UpdateAlertRequest, authorization: str = Header(None)):
    claims = verify_firebase_token(authorization)
    uid = claims["sub"]

    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE price_alerts SET target_price = %s WHERE product_id = %s AND user_id = %s",
            (body.target_price, product_id, uid),
        )
        conn.commit()
        return {"status": "ok"}
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


@app.delete("/api/alerts/{product_id}")
def delete_alert(product_id: str, authorization: str = Header(None)):
    claims = verify_firebase_token(authorization)
    uid = claims["sub"]

    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "DELETE FROM price_alerts WHERE product_id = %s AND user_id = %s",
            (product_id, uid),
        )
        conn.commit()
        return {"status": "ok"}
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


@app.get("/api/alerts/fired")
def get_fired_alerts(authorization: str = Header(None)):
    """Alerts belonging to the caller that scraper.py's price check has
    already flipped to is_active=false — used to drive the "an alert just
    triggered" indicator in the app without exposing other users' rows.
    """
    claims = verify_firebase_token(authorization)
    uid = claims["sub"]

    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute(
            """
            SELECT id, product_id, product_title, target_price
            FROM price_alerts
            WHERE user_id = %s AND is_active = false
            """,
            (uid,),
        )
        return {"items": cursor.fetchall()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@app.get("/")
def read_root():
    return {"message": "API is alive!"}

@app.get("/api/products")
def get_products(
    region: str = Query(None, description="Region to filter"),
    page: int = Query(None, ge=1, description="1-indexed page number; omit for the legacy unpaginated response"),
    limit: int = Query(24, ge=1, le=200, description="Items per page"),
):
    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Base query
        query = "SELECT * FROM products"
        where_clause = ""
        params = []

        # Filter by region if requested (matches "all_se" or "all_no")
        if region:
            where_clause = " WHERE feed_region LIKE %s"
            params.append(f"%{region.lower()}%")

        # Sort logic:
        # 1. Biggest percentage discounts first
        # 2. Then newest items
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
            # full-catalog visibility client-side (category/search filtering,
            # the "Insane Deals" ribbon, Recently Viewed).
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
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)