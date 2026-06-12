import time
from fastapi import FastAPI, Header, HTTPException, Depends
import httpx
from bs4 import BeautifulSoup
from firebase_admin import initialize_app, app_check

# Initialize Firebase Admin SDK for App Check verification
initialize_app()

app = FastAPI()

# In-memory cache: stores a dict of timestamp and data
CACHE_TTL = 300  # 5 minutes in seconds
cache = {"timestamp": 0, "data": []}

async def verify_appcheck(x_firebase_appcheck: str = Header(None)):
    if not x_firebase_appcheck:
        raise HTTPException(status_code=401, detail="Missing App Check token.")
    try:
        # Verifies the token and raises an error if it's invalid or expired
        app_check.verify_token(x_firebase_appcheck)
    except Exception as e:
        raise HTTPException(status_code=401, detail="Unauthorized request.")

@app.get("/api/products", dependencies=[Depends(verify_appcheck)])
async def get_products():
    """
    A starter template for scraping product deals.
    Replace the target URL and selectors with the actual site you are parsing.
    """
    now = time.time()
    # Return cached data if it's still fresh
    if cache["data"] and (now - cache["timestamp"]) < CACHE_TTL:
        return cache["data"]

    # Example URL (replace with a real retailer or aggregator)
    target_url = "https://example.com/deals"
    
    # headers = {
    #     "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
    # }
    # async with httpx.AsyncClient() as client:
    #     response = await client.get(target_url, headers=headers, timeout=10.0)
    #     soup = BeautifulSoup(response.text, "html.parser")
    
    scraped_products = []
    
    # TODO: Implement your BeautifulSoup parsing logic here. Example loop:
    # for item in soup.select('.product-card'):
    #     title = item.select_one('.title').text.strip()
    #     price_str = item.select_one('.price').text.replace('SEK', '').strip()
    #     price = float(price_str)
    #     
    #     scraped_products.append({
    #         "product_id": item.get('data-id', 'unknown'),
    #         "title": title,
    #         "brand": item.select_one('.brand').text.strip(),
    #         "price": price,
    #         "tracking_url": item.select_one('a')['href'],
    #         "image_url": item.select_one('img')['src']
    #     })

    # Dummy payload so your app can parse actual structures right away
    scraped_products = [
        {
            "product_id": "1",
            "title": "Sony WH-1000XM5 Wireless Headphones",
            "brand": "Sony",
            "price": 2990.0,
            "tracking_url": "https://example.com/sony-xm5",
            "image_url": "https://dummyimage.com/200x200/060919/00b4ff&text=Sony"
        }
    ]

    # Update the cache
    cache["timestamp"] = now
    cache["data"] = scraped_products

    return scraped_products

# Run locally with: uvicorn scraper_api:app --reload --port 8000