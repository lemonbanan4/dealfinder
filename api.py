import os
import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware

# Get connection string from environment
DATABASE_URL = os.environ.get("DATABASE_URL")

app = FastAPI(title="Prispuls Product Engine")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Use ["https://prispuls.com"] for final production
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
def get_products(region: str = Query(None)):
    conn = get_db_connection()
    # RealDictCursor makes the rows behave like Python dictionaries
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    if region:
        # Use %s for psycopg2 parameters, NOT ?
        cursor.execute("SELECT * FROM products WHERE feed_region = %s ORDER BY price ASC", (region,))
    else:
        cursor.execute("SELECT * FROM products ORDER BY last_updated DESC")
        
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return rows

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)