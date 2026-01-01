import asyncio
import os
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
print(f"Testing connection to: {DATABASE_URL}")

async def check_connection():
    try:
        # Create engine
        # Note: Neon requires SSL, but asyncpg often handles it. 
        # If it fails, we might need connect_args={"ssl": "require"}
        engine = create_async_engine(DATABASE_URL, echo=True)
        
        async with engine.connect() as conn:
            result = await conn.execute(text("SELECT version();"))
            version = result.scalar()
            print("Connection Successful!")
            print(f"PostgreSQL Version: {version}")
            
    except Exception as e:
        print("Connection Failed")
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_connection())
