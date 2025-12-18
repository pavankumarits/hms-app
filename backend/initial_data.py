import asyncio
from app.db.session import AsyncSessionLocal
from app.core import security
from app.models.user import User
from app.core.config import settings

async def init_db() -> None:
    async with AsyncSessionLocal() as db:
        username = "admin"
        password = "password"
        
        # Check if user exists
        from sqlalchemy.future import select
        result = await db.execute(select(User).filter(User.username == username))
        user = result.scalars().first()
        
        if not user:
            print(f"Creating superuser {username}...")
            user = User(
                username=username,
                hashed_password=security.get_password_hash(password),
                role="admin",
                is_active=True,
                is_superuser=True, # Assuming your model has this, or role handles it
            )
            db.add(user)
            await db.commit()
            print("Superuser created.")
        else:
            print(f"Superuser {username} already exists.")

if __name__ == "__main__":
    asyncio.run(init_db())
