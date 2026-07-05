import math
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware

# Get connection string from environment
DATABASE_URL = os.environ.get("DATABASE_URL")

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