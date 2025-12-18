import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from app.core.config import settings

# Parse the database name from the URL
# URL format: mysql+aiomysql://user:password@host/db_name
db_url = settings.DATABASE_URL
db_name = db_url.split("/")[-1]
server_url = db_url.rsplit("/", 1)[0]

async def create_db():
    # Connect to server without selecting database
    engine = create_async_engine(server_url, echo=True)
    async with engine.begin() as conn:
        await conn.execute(text(f"DROP DATABASE IF EXISTS {db_name}"))
        await conn.execute(text(f"CREATE DATABASE {db_name}"))
        print(f"Database {db_name} created.")
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(create_db())
