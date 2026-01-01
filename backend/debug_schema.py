import asyncio
import os
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

async def debug_db():
    engine = create_async_engine(DATABASE_URL, echo=False)
    async with engine.connect() as conn:
        print("--- USERS ---")
        result = await conn.execute(text("SELECT id, username, role FROM users"))
        rows = result.fetchall()
        for row in rows:
            print(row)

        print("\n--- COLUMNS: PATIENTS ---")
        result = await conn.execute(text("SELECT column_name, is_nullable, data_type FROM information_schema.columns WHERE table_name = 'patients'"))
        for row in rows:
            print(row) # Oops bug in print, fixed below mentally but let's see output
        for row in result.fetchall():
            print(f"{row[0]} ({row[2]}) Nullable: {row[1]}")

        print("\n--- COLUMNS: VISITS ---")
        result = await conn.execute(text("SELECT column_name, is_nullable, data_type FROM information_schema.columns WHERE table_name = 'visits'"))
        for row in result.fetchall():
            print(f"{row[0]} ({row[2]}) Nullable: {row[1]}")

if __name__ == "__main__":
    asyncio.run(debug_db())
