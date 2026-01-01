import asyncio
import os
from sqlalchemy.ext.asyncio import create_async_engine
from app.db.base import Base
from dotenv import load_dotenv

# Ensure we import all models so Base declares them
# (Already handled by importing app.db.base)

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

async def init_db():
    print("Creating tables in PostgreSQL...")
    # statement_cache_size=0 is required for PgBouncer/Neon Pooler
    engine = create_async_engine(DATABASE_URL, echo=True, connect_args={"statement_cache_size": 0})
    
    async with engine.begin() as conn:
        # Create all tables
        await conn.run_sync(Base.metadata.create_all)
    
    print("✅ Tables Created!")

if __name__ == "__main__":
    asyncio.run(init_db())
