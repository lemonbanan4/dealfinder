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
def get_products(region: str = Query(None, description="Region to filter")):
    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Base query
        query = "SELECT * FROM products"
        params = []
        
        # Filter by region if requested (matches "all_se" or "all_no")
        if region:
            query += " WHERE feed_region LIKE %s"
            params.append(f"%{region.lower()}%")

        # Sort logic:
        # 1. Biggest percentage discounts first
        # 2. Then newest items
        query += """
            ORDER BY
            CASE
                WHEN retail_price > price THEN (retail_price - price) / retail_price
                ELSE 0
            END DESC,
            last_updated DESC
        """
        cursor.execute(query, params)
        rows = cursor.fetchall()
        return rows
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