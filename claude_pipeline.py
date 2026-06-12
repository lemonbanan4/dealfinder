import os
import json
import sqlite3
from anthropic import Anthropic

# Initialize the Anthropic client (reads ANTHROPIC_API_KEY from environment)
client = Anthropic()

def inject_claude_purifier(raw_title, raw_description):
    """
    Injects Claude into the data feed pipeline to clean, categorize, 
    and extract specifications from messy product listings.
    """
    
    system_prompt = """
    You are a strict B2B Data Ingestion Agent for an e-commerce feed engine. 
    Your job is to parse messy vendor product titles and return a clean, structured JSON object.
    
    You must output ONLY a valid JSON object matching this schema exactly:
    {
        "clean_title": "String (Human-friendly, no tracking junk or caps lock)",
        "brand": "String (Normalized brand name)",
        "category": "String (Strictly choose one: Laptops, Monitors, Storage, Peripherals)",
        "specs": {
            "screen_size": "String or null",
            "ram_gb": Integer or null,
            "storage_gb": Integer or null,
            "gpu": "String or null"
        }
    }
    Do not include any conversational filler, markdown formatting (no ```json blocks), or extra text.
    """

    user_content = f"Raw Title: {raw_title}\nRaw Description: {raw_description}"

    try:
        # Call the Claude model
        response = client.messages.create(
            model="claude-3-5-sonnet-latest",
            max_tokens=1000,
            temperature=0.0,  # Zero temperature ensures deterministic, factual extraction
            system=system_prompt,
            messages=[{"role": "user", "content": user_content}]
        )
        
        # Parse the rigid JSON response directly
        cleaned_data = json.loads(response.content[0].text)
        return cleaned_data

    except Exception as e:
        print(f"Pipeline error processing row: {e}")
        return None

# --- Example of Hooking it up to your SQLite Database ---
def process_incoming_feed():
    conn = sqlite3.connect('prispuls.db')
    cursor = conn.cursor()
    
    # 1. Grab un-processed rows from your raw staging tables
    # (Assuming you dumped your raw feed into a staging table first)
    raw_item = ("ACER N5 N15-51-789X 15.6 W11 LAPTOP", "Brand new Acer laptop with 16GB RAM, 512GB SSD, and RTX 4050 graphics card.")
    
    print(f"🚀 Injecting Claude to clean: {raw_item[0]}")
    
    # 2. Let Claude process the row
    cleaned_result = inject_claude_purifier(raw_item[0], raw_item[1])
    
    if cleaned_result:
        print("✅ Structured JSON received from Claude:")
        print(json.dumps(cleaned_result, indent=2))
        
        # 3. Insert the beautiful structured data into your clean tables
        # cursor.execute("INSERT INTO master_products ...", (...))
        # conn.commit()

    conn.close()

if __name__ == "__main__":
    process_incoming_feed()