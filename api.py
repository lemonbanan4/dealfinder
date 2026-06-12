import sqlite3
from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Prispuls Product Engine")

# Enable CORS so your frontend website can safely read this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # When live, replace with ['https://prispuls.com']
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db_connection():
    conn = sqlite3.connect("prispuls.db")
    conn.row_factory = sqlite3.Row  # Enables fetching rows as dictionaries
    return conn

@app.get("/api/products")
def get_products(region: str = Query(None, description="Filter by 'Acer_Sweden' or 'Acer_Norway'")):
    """
    Fetches processed products from the local SQLite database to serve to the frontend.
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    
    if region:
        cursor.execute("SELECT * FROM products WHERE feed_region = ? ORDER BY price ASC", (region,))
    else:
        cursor.execute("SELECT * FROM products ORDER BY last_updated DESC")
        
    rows = cursor.fetchall()
    conn.close()
    
    # Convert SQL rows into clean JSON format
    return [dict(row) for row in rows]

if __name__ == "__main__":
    import uvicorn
    # Start the local server on port 8000
    uvicorn.run(app, host="0.0.0.0", port=8000)