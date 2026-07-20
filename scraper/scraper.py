"""
DealFinder FastAPI Scraper Service
DealFinder backend scraper
==========================
Fetches deals from Awin product feeds (Acer SE/NO) and HTML pages (Earfun),
then writes to Firestore /deals in the document shape expected by
FirestoreDealRepository in the Flutter app.

Usage
-----
Run locally with:
    uvicorn scraper:app --reload

The service exposes two endpoints:
  - GET /: A simple health check endpoint.
  - POST /run-scraper: Triggers the full scraping and database write process.

This service is designed to be deployed on Cloud Run and triggered by Cloud Scheduler.
"""

import hashlib
import io
import logging
import os
import re
import psycopg2
from psycopg2.extras import execute_values
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional
from urllib.parse import urlparse, quote

import pandas as pd
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv
from fastapi import FastAPI, BackgroundTasks
from supabase import create_client, Client

from google.cloud import secretmanager
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


# --- FastAPI App Initialization ---
app = FastAPI()

# Try to load .env for local development
load_dotenv()

# If the env var isn't found, it falls back to the secret injected by GitHub
supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_KEY")

# ── Logging ──────────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger(__name__)

# ── Constants ────────────────────────────────────────────────────────────────────

REQUEST_TIMEOUT = 30          # seconds; one broken store won't block the pipeline
FIRESTORE_BATCH_SIZE = 500    # Firestore hard limit per batch commit

# The FastAPI backend (api.py, deployed separately on Render) — used here
# only to reuse its /api/exchange-rates proxy rather than holding a second
# copy of the exchangerate-api.com key in this service too.
API_BASE_URL = os.environ.get("API_BASE_URL", "https://dealfinder-swr5.onrender.com")

# NOTE: the fallback value here is the same key that used to be hardcoded
# directly into all 18 STORES feed URLs below (and is therefore already in
# git history — this change alone doesn't rotate it). To actually secure
# this, get a fresh key from Awin's publisher dashboard, set it as an
# AWIN_API_KEY secret in this workflow's environment, and this fallback
# stops being used.
AWIN_API_KEY = os.environ.get("AWIN_API_KEY", "4a61258494661ab34c07bf7f5ec68c59")

MIN_DISCOUNT_PCT = float(os.environ.get("SCRAPER_MIN_DISCOUNT_PCT", "0"))

# ── Store configuration schema ───────────────────────────────────────────────────

@dataclass
class AwinConfig:
    """Configuration for stores served via Awin CSV product feeds."""
    feed_url: str
    # Optional: filter rows where the feed's 'currency' column matches this value.
    # Only needed when a single feed file mixes multiple currencies.
    currency_filter: Optional[str] = None
    # Map internal keys to external CSV column names
    column_map: dict[str, str] = field(default_factory=lambda: {
        "id": "merchant_product_id",
        "title": "product_name",
        "price": "search_price",
        "original_price": "rrp_price",
        "link": "aw_deep_link",
        "image": "merchant_image_url",
        "brand": "brand_name",
        "currency": "currency",
        "ean": "product_GTIN",
    })


@dataclass
class HtmlConfig:
    """Configuration for stores scraped via HTML + BeautifulSoup."""
    url: str
    # CSS selector for the repeating product card container
    list_selector: str
    # CSS selectors resolved relative to each product card
    title_selector: str
    current_price_selector: str
    link_selector: str
    # Selector for the strikethrough / compare-at / original price (nullable)
    original_price_selector: Optional[str] = None
    image_selector: Optional[str] = None
    # Prepended to relative hrefs (leave empty for absolute hrefs)
    base_url: str = ""
    # For a merchant that only offers Awin deep-link creation (no bulk CSV
    # feed) — wraps each scraped product URL in Awin's standard click-
    # redirect format (https://www.awin1.com/cread.php?awinmid=...&ued=...)
    # instead of linking to the bare product page. awinmid (merchant ID)
    # and awinaffid (your publisher ID) come from any deep link Awin's UI
    # generates for that merchant — both stay constant across every
    # product, only the `ued` (url-encoded destination) changes.
    awin_mid: Optional[str] = None
    awin_affid: Optional[str] = None


@dataclass
class StoreConfig:
    id: str        # Firestore document ID prefix, e.g. "acer_se"
    name: str      # Stored as deal.source in Firestore, shown in Flutter UI
    currency: str  # ISO 4217, e.g. "SEK", "NOK", "EUR"
    awin: Optional[AwinConfig] = None
    html: Optional[HtmlConfig] = None


# ── Store configurations ──────────────────────────────────────────────────────────
#
# Add or remove stores here.  Restart / redeploy the script for changes to take
# effect.  The Awin API key is embedded in the feed URL — rotate it in Awin's
# publisher dashboard and update these strings accordingly.

STORES: list[StoreConfig] = [

    StoreConfig(
        id="acer_se",
        name="Acer Sweden",
        currency="SEK",
        awin=AwinConfig(
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/62983/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,product_price_old,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/",
            currency_filter="SEK",
            column_map={
            "id": "merchant_product_id",
            "title": "product_name",
            "price": "search_price",
            "original_price": "product_price_old",
            "link": "aw_deep_link",
            "image": "aw_image_url",
            }
        ),
    ),

        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="samsung_se",
        name="Samsung Sweden",
        currency="SEK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/80731/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="navimow_se",
        name="Navimow Sweden",
        currency="SEK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/111829/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="diamondsmile_se",
        name="Diamond Smile Sweden",
        currency="SEK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/92875/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="babubas_se",
        name="Babubas Sweden",
        currency="SEK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/109860/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

    # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="sharkninja_se",
        name="SharkNinja Sweden",
        currency="SEK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/98123/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),


        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="deluxehomeartshop_se",
        name="Deluxe Home Art Shop Sweden",
        currency="SEK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/110453/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),


    # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="Bazta_se",
        name="Bazta Sweden",
        currency="SEK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/111947/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),


    # Just add a new block to your STORES list in scraper.py
    StoreConfig(
    id="perfumeza_se",
    name="Perfumeza Sweden",
    currency="SEK",
    awin=AwinConfig(
        # Paste the specific feed URL you got from the Awin interface for this store
        feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/112410/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
        currency_filter="SEK",
        column_map={
            "id": "merchant_product_id", # Verify these column names in your Awin feed
            "title": "product_name",
            "price": "search_price",
            "link": "aw_deep_link",
            "image": "aw_image_url",
        }
    ),
    ),



        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="plusshop_se",
        name="PlusShop Sweden",
        currency="SEK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/111985/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),


        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="dyson_se",
        name="Dyson Sweden",
        currency="SEK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/71335/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

    ### ---------- NORWAY deals ---------

        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="dyson_no",
        name="Dyson Norway",
        currency="NOK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/no/fid/71347/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="NOK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="sharkninja_no",
        name="SharkNinja Norway",
        currency="NOK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/no/fid/115464/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="NOK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="acer_no",
        name="Acer Norway",
        currency="NOK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/no/fid/62985/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="NOK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

        # Just add a new block to your STORES list in scraper.py
    StoreConfig(
        id="byvoks_no",
        name="Byvoks Norway",
        currency="NOK",
        awin=AwinConfig(
            # Paste the specific feed URL you got from the Awin interface for this store
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/no/fid/99323/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/", 
            currency_filter="NOK",
            column_map={
                "id": "merchant_product_id", # Verify these column names in your Awin feed
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),



    # Example of using the consolidated SE feed
    StoreConfig(
        id="samsung_no",
        name="Samsung NO",
        currency="NOK",
        awin=AwinConfig(
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/no/fid/84515/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,product_price_old,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/",
            currency_filter="NOK",
            column_map={
            "id": "merchant_product_id",
            "title": "product_name",
            "price": "search_price",
            "original_price": "product_price_old",
            "link": "aw_deep_link",
            "image": "aw_image_url"
            }
        ),
    ),


    # # ── Acer SE — Swedish store, prices in SEK ───────────────────────────────────
    # StoreConfig(
    #     id="acer_se",
    #     name="Acer SE",
    #     currency="SEK",
    #     awin=AwinConfig(
    #         feed_url=(
    #             "https://productdata.awin.com/datafeed/download/apikey/"
    #             "4a61258494661ab34c07bf7f5ec68c59/fid/65995/format/csv/language/sv/"
    #             "delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2C"
    #             "merchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2C"
    #             "aw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2C"
    #             "merchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cproduct_name%2C"
    #             "description%2Cpromotional_text%2Cmerchant_deep_link%2Cmerchant_image_url%2C"
    #             "delivery_time%2Csearch_price%2Crrp_price%2Cdelivery_cost%2Ccondition%2C"
    #             "colour%2Ccustom_1%2Ccustom_2%2Ccustom_3%2Ccustom_4%2Ccustom_5%2C"
    #             "delivery_restrictions%2Cstock_status%2Ccustom_6%2Ccustom_7%2Cproduct_GTIN/"
    #         ),
    #         # No currency_filter: the SE feed is Sweden-only, all rows are SEK.
    #     ),
    # ),

    # # ── Acer NO — Norwegian store, prices in NOK ─────────────────────────────────
    # StoreConfig(
    #     id="acer_no",
    #     name="Acer NO",
    #     currency="NOK",
    #     awin=AwinConfig(
    #         feed_url=(
    #             "https://productdata.awin.com/datafeed/download/apikey/"
    #             "4a61258494661ab34c07bf7f5ec68c59/fid/65993/format/csv/language/no/"
    #             "delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2C"
    #             "merchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2C"
    #             "aw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2C"
    #             "merchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cproduct_name%2C"
    #             "description%2Cpromotional_text%2Cmerchant_deep_link%2Cmerchant_image_url%2C"
    #             "delivery_time%2Ccurrency%2Csearch_price%2Crrp_price%2Cdelivery_cost%2C"
    #             "condition%2Ccolour%2Ccustom_1%2Ccustom_2%2Ccustom_4%2Ccustom_5%2C"
    #             "delivery_restrictions%2Cstock_status%2Ccustom_6%2Ccustom_7%2Cproduct_GTIN/"
    #         ),
    #         # This feed includes a 'currency' column — guard against multi-currency rows.
    #         currency_filter="NOK",
    #     ),
    # ),

    # ## SAMSUNG 
    # StoreConfig(
    #     id="samsung_se",
    #     name="Samsung SE",
    #     currency="SEK",
    #     awin=AwinConfig(
    #         feed_url=("https://productdata.awin.com/datafeed/download/apikey/4a61258494661ab34c07bf7f5ec68c59/fid/80731/format/csv/language/sv/delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2Cmerchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2Caw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2Cmerchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cisbn%2Cproduct_name%2Cdescription%2Cmerchant_deep_link%2Cmerchant_image_url%2Cdelivery_time%2Csearch_price%2Cin_stock%2Cstock_quantity%2Ccondition%2Cproduct_type%2Ccolour%2Ccustom_1%2Ccustom_2%2Ccustom_3%2Ccustom_4%2Ccustom_5%2Csaving%2Caverage_rating%2Calternate_image%2Cmerchant_product_second_category%2Cproduct_GTIN/"
    #                   ),
    #         currency_filter="SEK",
    #         column_map={
    #             "id": "merchant_product_id",
    #             "title": "product_name",
    #             "price": "search_price",
    #             "original_price": "product_price_old",
    #             "link": "aw_deep_link",
    #             "image": "merchant_image_url",
    #         }
    #     ),  
    # ),

    # StoreConfig(
    #     id="samsung_no",
    #     name="Samsung NO",
    #     currency="NOK",
    #     awin=AwinConfig(
    #         feed_url=("https://productdata.awin.com/datafeed/download/apikey/4a61258494661ab34c07bf7f5ec68c59/fid/84515/format/csv/language/no/delimiter/%2C/compression/gzip/columns/data_feed_id%2Cmerchant_id%2Cmerchant_name%2Caw_product_id%2Caw_deep_link%2Caw_image_url%2Caw_thumb_url%2Ccategory_id%2Ccategory_name%2Cbrand_id%2Cbrand_name%2Cmerchant_product_id%2Cmerchant_category%2Cean%2Cmpn%2Cisbn%2Cproduct_name%2Cdescription%2Cmerchant_deep_link%2Cmerchant_image_url%2Cdelivery_time%2Csearch_price%2Cin_stock%2Cstock_quantity%2Ccondition%2Cproduct_type%2Cparent_product_id%2Ccolour%2Ccustom_1%2Ccustom_2%2Ccustom_3%2Ccustom_4%2Csaving%2Caverage_rating%2Calternate_image%2Cmerchant_product_second_category%2Cproduct_price_old%2Cproduct_GTIN/"
    #         ),
    #         currency_filter="NOK",
    #         column_map={
    #             "id": "merchant_product_id",
    #             "title": "product_name",
    #             "price": "search_price",
    #             "original_price": "product_price_old",
    #             "link": "aw_deep_link",
    #             "image": "merchant_image_url",
    #         }
    #     ),  
    # ),


    # # ── Earfun — EU store, prices in EUR ─────────────────────────────────────────
    # #
    # # Earfun runs on Shopify (Dawn 2.x theme).  All product listings are
    # # server-side rendered, so BeautifulSoup works without a headless browser.
    # #
    # # If the site ever moves to a JS-first rendering approach, replace the html=
    # # block with a Playwright-based fetch or a Shopify Storefront API call
    # # (GET /products.json?limit=250).
    # StoreConfig(
    #     id="earfun",
    #     name="Earfun",
    #     currency="EUR",
    #     html=HtmlConfig(
    #         url="https://www.earfun.com/collections/all",
    #         list_selector="li.grid__item",
    #         title_selector=".card__heading a, h3.card__heading a",
    #         # On Shopify Dawn, sale cards carry both a <s> (original) and a
    #         # non-struck price element inside .price__sale.
    #         current_price_selector=(
    #             ".price__sale .price-item--sale, "
    #             ".price__regular .price-item--regular"
    #         ),
    #         original_price_selector=(
    #             ".price__sale s.price-item--regular, "
    #             ".price__sale .price-item--compare"
    #         ),
    #         link_selector=".card__heading a, a.full-unstyled-link",
    #         image_selector=".card__media img",
    #         base_url="https://www.earfun.com",
    #     ),
    # ),

    StoreConfig(
        id="xiaomi_se",
        name="Xiaomi Sweden",
        currency="SEK",
        awin=AwinConfig(
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/110674/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/",
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id",
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

    StoreConfig(
        id="didriksons_se",
        name="Didriksons Sweden",
        currency="SEK",
        awin=AwinConfig(
            feed_url=f"https://productdata.awin.com/datafeed/download/apikey/{AWIN_API_KEY}/language/sv/fid/115770/rid/0/hasEnhancedFeeds/0/columns/aw_deep_link,product_name,aw_product_id,merchant_product_id,merchant_image_url,description,merchant_category,search_price,merchant_name,merchant_id,category_name,category_id,aw_image_url,currency,store_price,delivery_cost,merchant_deep_link,language,last_updated,display_price,data_feed_id/format/csv/delimiter/%2C/compression/gzip/adultcontent/1/",
            currency_filter="SEK",
            column_map={
                "id": "merchant_product_id",
                "title": "product_name",
                "price": "search_price",
                "link": "aw_deep_link",
                "image": "aw_image_url",
            }
        ),
    ),

    # ── Voghion — SE store, no bulk Awin feed available for this merchant, ──────
    # only deep-link creation, so this scrapes se.voghion.com directly (Nuxt
    # SSR — product data is present in the raw server-rendered HTML, no
    # headless browser needed) and wraps each scraped product URL in Awin's
    # standard click-redirect format via awin_mid/awin_affid (see HtmlConfig)
    # instead of a per-product feed column. Homepage's "Just For You" section
    # is the only part of the site with product cards embedded in the initial
    # HTML (category/campaign pages fetch their listings client-side) — it's
    # somewhat personalized/rotating, so which ~29 products show up will vary
    # run to run, which is fine for a price-tracking scraper.
    StoreConfig(
        id="voghion_se",
        name="Voghion Sweden",
        currency="SEK",
        html=HtmlConfig(
            url="https://se.voghion.com",
            list_selector="a.just-for-you-item",
            title_selector="h3",
            current_price_selector=".text-18.font-bold",
            link_selector="self",
            image_selector="img",
            base_url="https://se.voghion.com",
            awin_mid="44635",
            awin_affid="2903781",
        ),
    ),
]

# ── Helpers ───────────────────────────────────────────────────────────────────────

def get_db_connection():
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        raise ValueError("DATABASE_URL is not set")
    # Use the connection string you got from Supabase (port 6543)
    return psycopg2.connect(db_url, sslmode='require')


def _make_doc_id(store_id: str, product_url: str, fallback_key: str = "") -> str:
    """
    Build a stable ID using the unique merchant_product_id.
    """
    if not product_url:
        product_url = ""
    # If we have a fallback_key (the merchant_product_id), use it as the slug!
    if fallback_key:
        slug = fallback_key
    else:
        path = urlparse(product_url).path.rstrip("/")
        slug = path.split("/")[-1] if path else ""
        if not slug:
            slug = hashlib.md5((product_url).encode()).hexdigest()[:16]

    raw = f"{store_id}_{slug}"
    # Firestore document IDs must not contain slashes; sanitise everything else too.
    return re.sub(r"[^a-zA-Z0-9_-]", "_", raw)[:200]


def get_column(row, aliases):
    """Helper to find a value from a row using a list of possible column names."""
    for alias in aliases:
        if alias in row:
            val = row[alias]
            if pd.notna(val):
                return val
    return None


def _parse_price(text: str) -> Optional[float]:
    """
    Parse a price string into a float, handling:
      • European decimal comma: "1.299,00" or "1 299,00"
      • English decimal point: "1,299.00" or "1299.00"
      • Currency symbols / whitespace stripped automatically
    """
    t = re.sub(r"[^\d.,\s]", "", text.strip()).strip()
    if not t:
        return None

    if "," in t and "." in t:
        if t.rfind(",") > t.rfind("."):
            # Handle cases like "1.299,00" (European)
            # e.g. "1.299,00" — European format
            t = t.replace(".", "").replace(",", ".")
        else:
            # e.g. "1,299.00" — English format
            t = t.replace(",", "")
    elif "," in t:
        parts = t.split(",")
        if len(parts) == 2 and len(parts[1]) in (1, 2):
            # Handle "79,99" -> "79.99"
            t = t.replace(",", ".")  # decimal comma: "79,99" → "79.99"
        else:
            # Handle "1,299" -> "1299"
            t = t.replace(",", "")

    try:
        return float(t)
    except ValueError:
        return None


def _discount_pct(original: float, current: float) -> float:
    if original <= 0:
        return 0.0
    return (original - current) / original * 100.0


def access_secret_version(project_id: str, secret_id: str, version_id: str = "latest") -> str:
    """
    Access the payload for the given secret version and return it.
    """
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")


# --- Email Alerting Logic --------------------------------------------------------
# --- Sending emails logic
SENDER_EMAIL = "contact@orbitroutine.com"
# The password is now fetched from Secret Manager inside check_and_fire_price_alerts
# SENDER_PASSWORD = "ggtp txgh lxcw koka" # REMOVED!

def send_alert_email(
    server: smtplib.SMTP,
    to_email: str,
    title: str, url: str, price: float, target: float
):
    msg = MIMEMultipart()
    msg['From'] = SENDER_EMAIL
    msg['To'] = to_email
    msg['Subject'] = f"🚨 Price Drop Alert: {title[:30]}..."

    html_body = f"""
    <h2>Your deal just dropped!</h2>
    <p>You asked us to track <strong>{title}</strong>.</p>
    <p>Your target price was {target}. The price just dropped to <strong>{price}</strong>!</p>
    <a href="{url}" style="padding: 10px 20px; background-color: #00B4FF; color: white; text-decoration: none; border-radius: 5px;">Grab the Deal Here</a>
    """
    
    msg.attach(MIMEText(html_body, 'html'))

    # Use the provided server connection to send the email
    try:
        server.send_message(msg)
        log.info("Successfully sent price alert email to %s", to_email)
        return True
    except Exception as e:
        # Use logger instead of print for consistency
        log.error("Failed to send email to %s: %s", to_email, e)
        return False

def _normalize_gmail_password(raw: str) -> str:
    """
    Strips whitespace and, for legacy payloads copied straight out of an
    old .env-style file into Secret Manager, a literal 'SENDER_PASSWORD='
    prefix and surrounding quotes. Applied to both the GMAIL_APP_PASSWORD
    env var and the Secret Manager fallback so copying the raw stored
    payload verbatim into either source behaves identically.
    """
    password = raw.strip()
    if password.startswith("SENDER_PASSWORD="):
        password = password[len("SENDER_PASSWORD="):].strip()
    if password.startswith('"') and password.endswith('"'):
        password = password[1:-1]
    elif password.startswith("'") and password.endswith("'"):
        password = password[1:-1]
    return password


def _fetch_sek_rates() -> Optional[Dict[str, float]]:
    """Conversion rates keyed by currency code, base SEK (rates[X] = how many
    units of X equal 1 SEK) — via api.py's /api/exchange-rates proxy, so this
    doesn't need its own copy of the exchangerate-api.com key. Returns None
    on any failure; callers should treat that as "skip conversion" rather
    than raising, since a stale/missing rate shouldn't block every alert
    check.
    """
    try:
        resp = requests.get(f"{API_BASE_URL}/api/exchange-rates", timeout=10)
        data = resp.json()
        if data.get("result") == "success":
            return {k: float(v) for k, v in data["conversion_rates"].items()}
    except Exception as exc:
        log.warning("Could not fetch exchange rates for alert check: %s", exc)
    return None


def check_and_fire_price_alerts(supabase):
    log.info("Checking for triggered price alerts...")

    alerts_response = supabase.table('price_alerts').select('*').eq('is_active', True).execute()

    active_alerts: List[Dict[str, Any]] = alerts_response.data or []

    if not active_alerts:
        log.info("No active alerts to check.")
        return

    # Fetch all product details in one query using the proper 'product_id' column name
    product_ids = {str(alert['product_id']) for alert in active_alerts}
    products_response = supabase.table('products').select('product_id, price, title, tracking_url, currency').in_('product_id', list(product_ids)).execute()

    products_data: List[Dict[str, Any]] = products_response.data or []

    if not products_data:
        log.warning("Could not fetch current prices/details for alerted products.")
        return

    product_map = {str(p['product_id']): p for p in products_data}
    alerts_to_deactivate = []

    # price_alerts.target_price is always denominated in SEK (the client
    # converts to SEK before saving — see price_alert_bottom_sheet.dart), but
    # products.price is in whatever currency that store's feed uses (several
    # NO stores are NOK). Comparing a NOK current_price directly against a
    # SEK target — as this used to — silently mispriced every alert on a
    # non-SEK product by the SEK/NOK exchange rate.
    sek_rates = _fetch_sek_rates()
    
    server = None
    try:
        # This job actually runs on a schedule via GitHub Actions (see
        # .github/workflows/scraper.yml) — a plain CI runner with no GCP
        # identity, so access_secret_version() below always fails there with
        # "Your default credentials were not found" (Secret Manager needs
        # Application Default Credentials, which only exist automatically in
        # a GCP execution context like Cloud Run). That failure was silently
        # swallowed by this function's own try/except, so every single
        # scheduled run has skipped sending price-drop emails entirely while
        # still reporting an overall "success" — the GMAIL_APP_PASSWORD env
        # var (set from a GitHub Actions secret) is the actual credential
        # source in that environment; Secret Manager remains the fallback
        # for any other execution context (e.g. a real Cloud Run deploy)
        # that does have a working GCP identity.
        env_password = os.environ.get("GMAIL_APP_PASSWORD")
        if env_password:
            log.info("Using Gmail app password from GMAIL_APP_PASSWORD env var.")
            sender_password = _normalize_gmail_password(env_password)
        else:
            log.info("Fetching Gmail app password from Secret Manager...")
            secret_payload = access_secret_version(
                project_id="dealfinderpro-bc5be", secret_id="Scraper"
            )
            sender_password = _normalize_gmail_password(secret_payload)

        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(SENDER_EMAIL, sender_password)

        for alert in active_alerts:
            try:
                product = product_map.get(str(alert['product_id']))
                if product is None:
                    continue

                current_price = float(product['price'])
                product_currency = (product.get('currency') or 'SEK').upper()
                if product_currency != 'SEK':
                    if sek_rates and product_currency in sek_rates:
                        current_price = current_price / sek_rates[product_currency]
                    else:
                        # No rate available — comparing raw NOK/EUR/etc.
                        # against a SEK target would be worse than not
                        # checking at all, so skip this one alert rather
                        # than risk a wrong-currency false fire.
                        log.warning(
                            "Skipping alert %s: no exchange rate for %s -> SEK",
                            alert['id'], product_currency,
                        )
                        continue

                if current_price <= float(alert['target_price']):
                    log.info("HIT! %s dropped to %s for %s", alert['product_title'], current_price, alert['user_email'])

                    # Fire the email using the existing server connection
                    success = send_alert_email(
                        server=server,
                        to_email=str(alert['user_email']),
                        title=str(product['title']),
                        url=str(product['tracking_url']),
                        price=current_price,
                        target=float(alert['target_price'])
                    )

                    if success:
                        alerts_to_deactivate.append(str(alert['id']))
            except Exception as exc:
                # One malformed/unexpected alert shouldn't abort the whole
                # batch — log it and keep processing the rest.
                log.error("Failed to process alert %s: %s", alert.get('id'), exc)

    except Exception as e:
        log.error("Failed to establish SMTP connection: %s", e)
    finally:
        # Always release the socket, even if something above raised —
        # previously an exception mid-loop skipped server.quit() entirely,
        # leaking the connection until GC/timeout.
        if server is not None:
            try:
                server.quit()
            except Exception:
                pass

    # Deactivate whatever fired successfully, regardless of what happened
    # afterward — otherwise an error later in the run would leave already-
    # emailed alerts active, and they'd fire (and email) again next run.
    if alerts_to_deactivate:
        supabase.table('price_alerts').update({'is_active': False}).in_('id', alerts_to_deactivate).execute()
        log.info("Successfully deactivated %d alerts.", len(alerts_to_deactivate))

    return


# ── Awin feed fetcher ─────────────────────────────────────────────────────────────

def fetch_awin_deals(store: StoreConfig) -> list[dict]:
    """Download and parse an Awin CSV product feed; return deal dicts."""
    cfg = store.awin
    assert cfg is not None

    log.info("[%s] Downloading Awin CSV feed…", store.name)
    try:
        resp = requests.get(
            cfg.feed_url,
            headers={"Accept-Encoding": "gzip, deflate"},
            timeout=REQUEST_TIMEOUT,
        )
        resp.raise_for_status()
    except requests.exceptions.Timeout:
        log.error(
            "[%s] Awin feed timed out after %ds — skipping store.",
            store.name, REQUEST_TIMEOUT,
        )
        return []
    except requests.exceptions.RequestException as exc:
        log.error("[%s] Awin feed network error (%s) — skipping store.", store.name, exc)
        return []

    try:
        df = pd.read_csv(io.BytesIO(resp.content), compression="gzip", low_memory=False)
    except Exception as exc:
        log.error("[%s] Failed to parse Awin CSV (%s) — skipping store.", store.name, exc)
        return []

    log.info("[%s] %d raw rows received.", store.name, len(df))
    log.info("[%s] Column headers: %s", store.name, list(df.columns))
    log.info("[%s] Sample row: %s", store.name, df.head(1).to_dict())


    link_col = cfg.column_map["link"]
    price_col = cfg.column_map["price"]
    rrp_col = cfg.column_map.get("original_price")

    # Drop rows missing required fields.
    df = df.dropna(subset=[link_col, price_col])
    df = df.dropna(subset=["search_price"])

    # Filter to the target currency when the feed mixes multiple currencies.
    if cfg.currency_filter and "currency" in df.columns:
        df = df[df["currency"].str.upper() == cfg.currency_filter.upper()]

    
    df[price_col] = pd.to_numeric(df[price_col], errors="coerce")
    if rrp_col and rrp_col in df.columns:
        df[rrp_col] = pd.to_numeric(df[rrp_col], errors="coerce")
    df = df.dropna(subset=[price_col])
    # Gift cards / free-item rows ("Presentkort" etc.) come through the feed
    # with a literal 0 price — kept before this point only because dropna
    # doesn't catch 0, they'd otherwise read as a permanent, fake "100% off"
    # deal (any historical price is "higher" than free) once in `products`.
    df = df[df[price_col] > 0]

    # Identify rows that have a valid, higher RRP — but do NOT discard the rest.
    # Products where rrp_price is missing or ≤ search_price are kept and stored
    # with originalPrice = None so all 200+ products flow through.
    #has_discount = df["rrp_price"].notna() & (df["rrp_price"] > df["search_price"])

    if rrp_col and rrp_col in df.columns:
        has_discount = df[rrp_col].notna() & (df[rrp_col] > df[price_col])
    else:
        has_discount = pd.Series([False] * len(df))

    # SCRAPER_MIN_DISCOUNT_PCT only drops rows that *have* an RRP but fall below
    # the threshold.  Rows without any RRP are always kept.
    if MIN_DISCOUNT_PCT > 0:
        below_threshold = has_discount & (
            (df["rrp_price"] - df["search_price"]) / df["rrp_price"] * 100
            < MIN_DISCOUNT_PCT
        )
        df = df[~below_threshold]
        has_discount = df["rrp_price"].notna() & (df["rrp_price"] > df["search_price"])

    log.info(
        "[%s] %d products kept (%d with discount, %d without RRP).",
        store.name, len(df), int(has_discount.sum()), int((~has_discount).sum()),
    )

    deals: list[dict] = []
    for _, row in df.iterrows():
        raw_id = str(row.get(cfg.column_map["id"], ""))
        title = str(row.get(cfg.column_map["title"], ""))
        url = str(row.get(cfg.column_map["link"], "")).strip()


        # Use our helper for prices to handle different column names
        current_price = float(pd.to_numeric(row.get(cfg.column_map["price"], 0), errors='coerce'))



        # Original price (handle if it doesn't exists)
        orig_col_name = cfg.column_map.get("original_price")
        rrp = row.get(orig_col_name) if orig_col_name and orig_col_name in row else None
        original_price = float(rrp) if pd.notna(rrp) and float(rrp) > current_price else None


        deals.append({
            "id": _make_doc_id(store.id, url, fallback_key=raw_id),
            "title": title,
            "url": url,
            "source": store.name,
            "currentPrice": current_price,
            "currency": row.get(cfg.column_map.get("currency", "currency"), store.currency),
            "imageUrl": row.get(cfg.column_map["image"]),
            "originalPrice": original_price,
            "description": row.get(cfg.column_map.get("description", "description"), ""),
            "ean": row.get(cfg.column_map.get("ean", "ean")),
            "brand": row.get("brand_name", "Unknown")
        })

    return deals


# ── HTML / BeautifulSoup fetcher ──────────────────────────────────────────────────

# Full browser-grade header set to pass Shopify's WAF checks.
# UNEXPECTED_EOF_WHILE_READING means Shopify closed the TLS connection on
# detecting a non-browser client.  Sec-Fetch-* headers and a realistic
# Accept-Encoding are usually enough to get through.
#
# If it still fails, the reliable fix is `curl-cffi`, which clones Chrome's
# exact TLS fingerprint (JA3 hash):
#   pip install curl-cffi
#   from curl_cffi import requests as cf
#   resp = cf.get(url, impersonate="chrome124", timeout=REQUEST_TIMEOUT)
_HTML_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": (
        "text/html,application/xhtml+xml,application/xml;q=0.9,"
        "image/avif,image/webp,image/apng,*/*;q=0.8,"
        "application/signed-exchange;v=b3;q=0.7"
    ),
    "Accept-Language": "en-US,en;q=0.9",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Cache-Control": "max-age=0",
}


def _resolve_image(img_tag) -> Optional[str]:
    """
    Extract the best image URL from a <img> tag.

    Shopify lazy-loads via data-src or a srcset attribute; BeautifulSoup sees
    the raw HTML before JavaScript runs, so we check all three attributes.
    """
    if img_tag is None:
        return None
    src = (
        img_tag.get("src")
        or img_tag.get("data-src")
        or (img_tag.get("srcset", "").split(" ")[0] if img_tag.get("srcset") else None)
    )
    if src and src.startswith("//"):
        src = "https:" + src
    return src or None


def fetch_html_deals(store: StoreConfig) -> list[dict]:
    """Scrape an HTML product listing page; return deal dicts."""
    cfg = store.html
    assert cfg is not None

    log.info("[%s] Fetching %s …", store.name, cfg.url)
    try:
        resp = requests.get(cfg.url, headers=_HTML_HEADERS, timeout=REQUEST_TIMEOUT)
        resp.raise_for_status()
    except requests.exceptions.Timeout:
        log.error(
            "[%s] Page request timed out after %ds — skipping store.",
            store.name, REQUEST_TIMEOUT,
        )
        return []
    except requests.exceptions.RequestException as exc:
        log.error("[%s] Page network error (%s) — skipping store.", store.name, exc)
        return []

    soup = BeautifulSoup(resp.text, "lxml")
    items = soup.select(cfg.list_selector)
    log.info("[%s] %d product cards found in DOM.", store.name, len(items))

    deals: list[dict] = []
    for item in items:
        title_el = item.select_one(cfg.title_selector)
        price_el = item.select_one(cfg.current_price_selector)
        # `select_one` only searches descendants of `item`, never `item`
        # itself — fine for a card that's a wrapper (<li>/<div>) around a
        # nested <a>, but some sites' card markup makes the <a> the card
        # itself (no separate link element to select). link_selector="self"
        # opts into using `item`'s own href in that case.
        link_el = item if cfg.link_selector == "self" else item.select_one(cfg.link_selector)

        if not (title_el and price_el and link_el):
            continue

        title = title_el.get_text(strip=True)
        current_price = _parse_price(price_el.get_text())
        if current_price is None or current_price <= 0:
            continue

        href_value = link_el.get("href")
        if isinstance(href_value, list):
            href = href_value[0] if href_value else ""
        elif href_value is None:
            href = ""
        else:
            href = str(href_value)

        if href.startswith("/"):
            href = cfg.base_url + href
        if not href:
            continue

        # Doc ID must come from the real per-product page URL — every
        # Awin cread.php redirect shares the exact same path (/cread.php);
        # the actual product identity only lives in the `ued=` query
        # string, which urlparse().path (see _make_doc_id) ignores. Wrapping
        # first and hashing the wrapped URL made every product on a page
        # resolve to the identical doc ID (all "{store}_cread_php"),
        # silently collapsing an entire store's catalog down to one row.
        doc_id = _make_doc_id(store.id, href)

        if cfg.awin_mid and cfg.awin_affid:
            href = (
                "https://www.awin1.com/cread.php"
                f"?awinmid={cfg.awin_mid}&awinaffid={cfg.awin_affid}"
                f"&ued={quote(href, safe='')}"
            )

        original_price: Optional[float] = None
        if cfg.original_price_selector:
            orig_el = item.select_one(cfg.original_price_selector)
            if orig_el:
                parsed = _parse_price(orig_el.get_text())
                # Sanity check: original price must actually be higher.
                if parsed is not None and parsed > current_price:
                    original_price = parsed

        # Apply minimum discount threshold (original_price must exist for HTML stores).
        if MIN_DISCOUNT_PCT > 0:
            if original_price is None:
                continue
            if _discount_pct(original_price, current_price) < MIN_DISCOUNT_PCT:
                continue

        image_url = _resolve_image(
            item.select_one(cfg.image_selector) if cfg.image_selector else None
        )

        deals.append({
            "id": doc_id,
            "title": title,
            "url": href,
            "source": store.name,
            "currentPrice": current_price,
            "currency": store.currency,
            "imageUrl": image_url,
            "originalPrice": original_price,
        })

    log.info("[%s] %d valid deals parsed.", store.name, len(deals))
    return deals


# ── Firestore writer ──────────────────────────────────────────────────────────────

def _diff_price_history(cur, deals: list[dict]) -> list[dict]:
    """
    Compares each deal's current feed price against the most recently
    recorded `price_history` entry for that product (before this run's own
    write), so a "price dropped" signal reflects an actual decrease rather
    than just the fact that a price_history row was written — a row gets
    written on every scrape run regardless of whether the price moved, so
    without this diff there was no way to tell a real drop from a re-scrape
    of an unchanged price.

    Returns the subset of `deals` whose current price is strictly lower than
    their last recorded price_history price, each annotated with
    previous_price/drop_pct.
    """
    product_ids = [deal["id"] for deal in deals]
    if not product_ids:
        return []

    cur.execute(
        """
        SELECT DISTINCT ON (product_id) product_id, price
        FROM price_history
        WHERE product_id = ANY(%s)
        ORDER BY product_id, recorded_at DESC
        """,
        (product_ids,),
    )
    last_prices = {row[0]: float(row[1]) for row in cur.fetchall()}

    drops = []
    for deal in deals:
        last_price = last_prices.get(deal["id"])
        current_price = deal["currentPrice"]
        if last_price is not None and current_price < last_price:
            drops.append({
                "id": deal["id"],
                "title": deal["title"],
                "previous_price": last_price,
                "current_price": current_price,
                "drop_pct": _discount_pct(last_price, current_price),
            })
    return drops


def write_deals(deals: list[dict], store_id: str) -> int:
    conn = get_db_connection()
    cur = conn.cursor()

    upsert_query = """
    INSERT INTO products (
        product_id, feed_region, title, brand, price, 
        retail_price, tracking_url, image_url, description,
        stock_status, ean_code
    ) VALUES %s
    ON CONFLICT (product_id) 
    DO UPDATE SET 
        price = EXCLUDED.price,
        tracking_url = EXCLUDED.tracking_url,
        image_url = EXCLUDED.image_url,
        retail_price = EXCLUDED.retail_price,
        stock_status = EXCLUDED.stock_status,
        description = EXCLUDED.description,
        ean_code = EXCLUDED.ean_code, 
        last_updated = timezone('utc'::text, now());
    """

    price_history_query = """
    INSERT INTO price_history (product_id, price)
    VALUES %s ON CONFLICT DO NOTHING;
    """
    
    # A single `INSERT ... ON CONFLICT DO UPDATE` can't affect the same row
    # twice — Postgres errors out the whole batch if `deal["id"]` repeats
    # (e.g. a listing page that lists the same product in two sections, like
    # Voghion's "just for you" carousel). De-duping here (last occurrence
    # wins) keeps one bad duplicate from failing every product in the run.
    deduped_deals = list({deal["id"]: deal for deal in deals}.values())

    product_values = [
        (
            deal["id"],
            store_id,
            deal["title"],
            deal.get("brand", "unknown"),
            deal["currentPrice"],
            deal["originalPrice"],
            deal["url"],
            deal["imageUrl"],
            deal.get("description", ""),
            "In Stock",
            str(deal.get("ean")) if deal.get("ean") else None
        )
        for deal in deduped_deals
    ]

    history_values = [
        (deal["id"], deal["currentPrice"])
        for deal in deduped_deals
    ]

    try:
        price_drops = _diff_price_history(cur, deals)
        if price_drops:
            log.info(
                "[%s] %d confirmed price drop(s) this run: %s",
                store_id,
                len(price_drops),
                ", ".join(
                    f"{d['title'][:40]!r} {d['previous_price']:.2f} -> "
                    f"{d['current_price']:.2f} (-{d['drop_pct']:.1f}%)"
                    for d in price_drops[:5]
                ),
            )

        execute_values(cur, upsert_query, product_values)
        execute_values(cur, price_history_query, history_values)
        conn.commit()
    except Exception as e:
        conn.rollback()
        log.error("Failed to execute batch insert: %s", e)
        raise e
    finally:
        cur.close()
        conn.close()

    return len(deals)

# ── Per-store dispatch ────────────────────────────────────────────────────────────

def scrape_store(store: StoreConfig) -> list[dict]:
    if store.awin:
        return fetch_awin_deals(store)
    if store.html:
        return fetch_html_deals(store)
    log.warning("[%s] No awin or html config defined — skipped.", store.name)
    return []


# ── Entry point ───────────────────────────────────────────────────────────────────

def run_scraper_process():
    if not supabase_url or not supabase_key:
        raise ValueError("Missing Supabase environment variables.")
    
    supabase: Client = create_client(supabase_url, supabase_key)

    # ── Scrape and Write Store by Store ──────────────────────────────────────────
    for store in STORES:
        try:
            deals = scrape_store(store)
            if deals:
                log.info("[%s] Writing %d deals to Supabase...", store.name, len(deals))
                written = write_deals(deals, store.id)
                log.info("[%s] Successfully wrote %d deals.", store.name, written)
        except Exception as exc:
            log.exception("[%s] Unexpected error — store skipped: %s", store.name, exc)

    log.info("Pipeline complete.")

    # Assuming 'supabase' is your initialized client
    check_and_fire_price_alerts(supabase)


# --- API Endpoints ---------------------------------------------------------------

@app.get("/")
def health_check():
    """A simple health check endpoint to confirm the service is running."""
    return {"status": "ok", "message": "Scraper API is running."}


@app.post("/run-scraper")
async def trigger_scraper(background_tasks: BackgroundTasks):
    """
    Triggers the scraping process in the background.
    This endpoint returns immediately with a confirmation message.
    """
    log.info("Received request to /run-scraper. Starting job in background.")
    background_tasks.add_task(run_scraper_process)
    return {"message": "Scraper job started in the background."}


# This block allows running the script directly for legacy/testing purposes,
# but it's not used when running with a web server like Uvicorn.
if __name__ == "__main__":
    log.info("Running scraper directly as a script.")
    run_scraper_process()
    log.info("Script finished.")
