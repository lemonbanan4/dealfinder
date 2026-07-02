import os
from typing import List, Optional

import psycopg2
import psycopg2.extras
from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from .dependencies import verify_app_check

# Try to load .env for local development
load_dotenv()

# --- App Initialization and CORS ---
app = FastAPI(
    title="DealFinder Scraper API",
    description="API to serve deals scraped from various sources.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Database Connection ---
def get_db_connection():
    """Establish a connection to the PostgreSQL database using environment variables."""
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        raise HTTPException(status_code=500, detail="DATABASE_URL environment variable not set")
    try:
        conn = psycopg2.connect(db_url, sslmode='require')
        return conn
    except psycopg2.OperationalError as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")


# --- Pydantic Models (for response validation) ---
class Deal(BaseModel):
    id: str = Field(..., alias="product_id")
    title: str
    source: str = Field(..., alias="brand")
    url: str = Field(..., alias="tracking_url")
    imageUrl: Optional[str] = Field(None, alias="image_url")
    currentPrice: float = Field(..., alias="price")
    originalPrice: Optional[float] = Field(None, alias="retail_price") # This comes from the DB
    currency: str = "SEK"

    class Config:
        orm_mode = True
        allow_population_by_field_name = True

# API Endpoints
@app.get("/")
def read_root():
    """Root endpoint to check if the API is running."""
    return {"status": "ok", "message": "Welcome to the DealFinder Scraper API!"}

@app.get("/deals", response_model=List[Deal], dependencies=[Depends(verify_app_check)])
def get_deals(
    q: Optional[str] = Query(None, description="Search query to filter titles"),
    sort_by: Optional[str] = Query("last_updated", description="Column to sort by (e.g., 'price', 'title')"),
    order: Optional[str] = Query("desc", description="Sort order ('asc' or 'desc')"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
):
    """
    Fetches deals from the database with optional filtering, sorting, and pagination.
    """
    conn = get_db_connection()
    # Use RealDictCursor to get rows as dictionaries
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    # --- Build the SQL Query ---
    base_query = "SELECT * FROM products"
    where_clauses = []
    params = []

    if q:
        where_clauses.append("title ILIKE %s")
        params.append(f"%{q}%")

    if where_clauses:
        base_query += " WHERE " + " AND ".join(where_clauses)

    # --- Sorting Logic (with sanitization) ---
    allowed_sort_columns = ["title", "price", "brand", "last_updated"]
    if sort_by not in allowed_sort_columns:
        sort_by = "last_updated"  # Default to a safe, indexed column

    if order.lower() not in ["asc", "desc"]:
        order = "desc"

    base_query += f" ORDER BY {sort_by} {order.upper()}"

    # --- Pagination ---
    base_query += " LIMIT %s OFFSET %s"
    params.extend([limit, offset])

    try:
        cursor.execute(base_query, tuple(params))
        deals_from_db = cursor.fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to query database: {e}")
    finally:
        cursor.close()
        conn.close()

    # Pydantic will automatically handle the mapping from the dictionary keys
    # to the Deal model fields, including aliases.
    return deals_from_db
