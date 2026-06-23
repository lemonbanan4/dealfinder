import io
import os
import sqlite3
import requests
import pandas as pd
import pprint

def fetch_and_process_awin_feed(feed_url, target_currency=None):
    """
    Downloads an Awin product data feed, cleans it, and maps it to a unified database structure.
    Explicitly forces GZIP decompression to handle Awin API data streams.
    """
    print(f"Initiating download for feed...")
    
    try:
        # 1. Fetch the data securely
        headers = {"Accept-Encoding": "gzip, deflate"}
        response = requests.get(feed_url, headers=headers, timeout=60)
        response.raise_for_status()
        print("Download complete. Decompressing and parsing CSV layout...")
        
        # 2. Ingest into Pandas - FORCING 'gzip' compression explicitly bypasses extension checking
        df = pd.read_csv(io.BytesIO(response.content), compression='gzip', low_memory=False)
        print(f"RAW DOWNLOAD COUNT: {len(df)} rows found before filtering.")
        
        # 3. Data Cleansing & Sanitization
        df = df.dropna(subset=['aw_deep_link', 'search_price'])
        df['search_price'] = pd.to_numeric(df['search_price'], errors='coerce')
        
        # 4. Dynamic Currency Filtering
        if target_currency and 'currency' in df.columns:
            df = df[df['currency'].str.upper() == target_currency.upper()]
            
        print(f"Total clean records extracted: {len(df)}")
        
        # 5. Build Normalized Dictionary Payload
        processed_products = []
        for _, row in df.iterrows():
            product_data = {
                "product_id": str(row.get("merchant_product_id")),
                "title": row.get("product_name"),
                "brand": row.get("brand_name"),
                "price": row.get("search_price"),
                "retail_price": row.get("rrp_price"),
                "tracking_url": row.get("aw_deep_link"),
                "image_url": row.get("merchant_image_url"),
                "description": row.get("description"),
                "stock_status": row.get("stock_status"),
                "ean_code": str(row.get("product_GTIN")) if pd.notna(row.get("product_GTIN")) else None
            }
            processed_products.append(product_data)
            
        return processed_products

    except requests.exceptions.RequestException as e:
        print(f"Network error processing feed: {e}")
        return []
    except Exception as e:
        print(f"Parsing compilation failure: {e}")
        return []


def save_catalog_to_database(master_catalog, db_path="prispuls.db"):
    """
    Connects to SQLite, ensures the table architecture exists, 
    and handles automatic UPSERTS (Insert or Replace) for all products.
    """
    print("\n--- Connecting to SQLite Engine ---")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Create the price comparison schema table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS products (
            product_id TEXT PRIMARY KEY,
            feed_region TEXT,
            title TEXT,
            brand TEXT,
            price REAL,
            retail_price REAL,
            tracking_url TEXT,
            image_url TEXT,
            description TEXT,
            stock_status TEXT,
            ean_code TEXT,
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    total_sync_count = 0
    
    for region_name, product_list in master_catalog.items():
        print(f"Syncing {len(product_list)} items from {region_name} into database rows...")
        for prod in product_list:
            cursor.execute("""
                INSERT OR REPLACE INTO products (
                    product_id, feed_region, title, brand, price, retail_price, 
                    tracking_url, image_url, description, stock_status, ean_code, last_updated
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
            """, (
                prod["product_id"],
                region_name,
                prod["title"],
                prod["brand"],
                prod["price"],
                prod["retail_price"],
                prod["tracking_url"],
                prod["image_url"],
                prod["description"],
                prod["stock_status"],
                prod["ean_code"]
            ))
            total_sync_count += 1
            
    conn.commit()
    conn.close()
    print(f"Database Synchronization Complete. Saved {total_sync_count} total records to '{db_path}'.")


if __name__ == "__main__":
    FEEDS_TO_RUN = {
        "Acer_Sweden": {
            "url": "https://productdata.awin.com/datafeed/download/apikey/4a61258494661ab34c07bf7f5ec68c59/fid/65995/format/csv/language/sv/delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2Cmerchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2Caw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2Cmerchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cproduct_name%2Cdescription%2Cpromotional_text%2Cmerchant_deep_link%2Cmerchant_image_url%2Cdelivery_time%2Csearch_price%2Crrp_price%2Cdelivery_cost%2Ccondition%2Ccolour%2Ccustom_1%2Ccustom_2%2Ccustom_3%2Ccustom_4%2Ccustom_5%2Cdelivery_restrictions%2Cstock_status%2Ccustom_6%2Ccustom_7%2Cproduct_GTIN/",
            "currency": "SEK"
        },
        "Acer_Norway": {
             "url": "https://productdata.awin.com/datafeed/download/apikey/4a61258494661ab34c07bf7f5ec68c59/fid/65993/format/csv/language/no/delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2Cmerchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2Caw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2Cmerchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cproduct_name%2Cdescription%2Cpromotional_text%2Cmerchant_deep_link%2Cmerchant_image_url%2Cdelivery_time%2Ccurrency%2Csearch_price%2Crrp_price%2Cdelivery_cost%2Ccondition%2Ccolour%2Ccustom_1%2Ccustom_2%2Ccustom_4%2Ccustom_5%2Cdelivery_restrictions%2Cstock_status%2Ccustom_6%2Ccustom_7%2Cproduct_GTIN/",
             "currency": "NOK"
        },
        "Samsung_Sweden": {
            "url": "https://productdata.awin.com/datafeed/download/apikey/4a61258494661ab34c07bf7f5ec68c59/fid/80731/format/csv/language/sv/delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2Cmerchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2Caw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2Cmerchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cisbn%2Cproduct_name%2Cdescription%2Cmerchant_deep_link%2Cmerchant_image_url%2Cdelivery_time%2Csearch_price%2Cin_stock%2Cstock_quantity%2Ccondition%2Cproduct_type%2Ccolour%2Ccustom_1%2Ccustom_2%2Ccustom_3%2Ccustom_4%2Ccustom_5%2Csaving%2Caverage_rating%2Calternate_image%2Cmerchant_product_second_category%2Cproduct_GTIN/",
            "currency": "SEK"
        },
        "Samsung_Norway": {
            "url": "https://productdata.awin.com/datafeed/download/apikey/4a61258494661ab34c07bf7f5ec68c59/fid/84515/format/csv/language/no/delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2Cmerchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2Caw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2Cmerchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cisbn%2Cproduct_name%2Cdescription%2Cmerchant_deep_link%2Cmerchant_image_url%2Cdelivery_time%2Csearch_price%2Cin_stock%2Cstock_quantity%2Ccondition%2Cproduct_type%2Cparent_product_id%2Ccolour%2Ccustom_1%2Ccustom_2%2Ccustom_3%2Ccustom_4%2Csaving%2Caverage_rating%2Calternate_image%2Cmerchant_product_second_category%2Cproduct_price_old%2Cproduct_GTIN/",
            "currency": "NOK"
        }
    }
    master_catalog = {}
    
    for feed_name, config in FEEDS_TO_RUN.items():
        print(f"\n--- Starting Pipeline Processing for: {feed_name} ---")
        store_items = fetch_and_process_awin_feed(config["url"], target_currency=config["currency"])
        master_catalog[feed_name] = store_items
        
    # Verification Output Prints
    if master_catalog.get("Acer_Sweden") and len(master_catalog["Acer_Sweden"]) > 0:
        print("\n--- Live Verification Sample: Acer Sweden ---")
        pprint.pprint(master_catalog["Acer_Sweden"][0])
        
    if master_catalog.get("Acer_Norway") and len(master_catalog["Acer_Norway"]) > 0:
        print("\n--- Live Verification Sample: Acer Norway ---")
        pprint.pprint(master_catalog["Acer_Norway"][0])

    if master_catalog.get("Samsung_Sweden") and len(master_catalog["Samsung_Sweden"]) > 0:
        print("\n--- Live Verification Sample: Samsung Sweden ---")
        pprint.pprint(master_catalog["Samsung_Sweden"][0])

    if master_catalog.get("Samsung_Norway") and len(master_catalog["Samsung_Norway"]) > 0:
        print("\n--- Live Verification Sample: Samsung Norway ---")
        pprint.pprint(master_catalog["Samsung_Norway"][0])

    # Run Database Sync Engine
    if any(master_catalog.values()):
        save_catalog_to_database(master_catalog)