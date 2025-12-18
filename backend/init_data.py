import asyncio
from sqlalchemy.future import select
from app.db.session import AsyncSessionLocal
from app.models.user import User
from app.core.security import get_password_hash

async def create_init_data():
    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User).filter(User.username == "admin"))
        user = result.scalars().first()
        
        if not user:
            print("Creating initial admin user...")
            user = User(
                username="admin",
                hashed_password=get_password_hash("admin"),
                role="admin",
                is_active=True
            )
            session.add(user)
            await session.commit()
            print("Admin user created (username: admin, password: admin)")
        else:
            print("Admin user already exists.")

if __name__ == "__main__":
    asyncio.run(create_init_data())
