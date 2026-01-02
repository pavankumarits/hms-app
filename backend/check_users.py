import asyncio
import sys
import os

backend_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(backend_dir)

from dotenv import load_dotenv
load_dotenv(os.path.join(backend_dir, ".env"))

from app.db.session import AsyncSessionLocal
from app.models.user import User
from sqlalchemy import select

async def list_users():
    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User))
        users = result.scalars().all()
        print(f"Total Users: {len(users)}")
        for u in users:
            print(f" - User: {u.username}, Role: {u.role}, Active: {u.is_active}")
            
        if not users:
            print("❌ NO USERS FOUND. Database is empty.")

if __name__ == "__main__":
    asyncio.run(list_users())
