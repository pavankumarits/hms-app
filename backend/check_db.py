import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from app.core.config import settings
from sqlalchemy import make_url
import sys

# Parse the URL to get the base URL without database
url = make_url(settings.DATABASE_URL)
DB_NAME = url.database
# Remove database from URL for initial connection
DB_URL_NO_DB = url.set(database='').render_as_string(hide_password=False)

async def check_database():
    print(f"Connecting to MySQL at {DB_URL_NO_DB}...")
    try:
        engine = create_async_engine(DB_URL_NO_DB)
        async with engine.connect() as conn:
            await conn.execute(text(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}"))
            print(f"SUCCESS: Database '{DB_NAME}' created or already exists.")
        await engine.dispose()
    except Exception as e:
        print(f"ERROR: Could not connect to database. {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(check_database())
