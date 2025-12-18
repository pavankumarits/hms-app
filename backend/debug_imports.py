import sys
print("Starting debug...")
try:
    print("Importing config...")
    from app.core.config import settings
    print(f"Config imported. DB URL: {settings.DATABASE_URL}")
    
    print("Importing Base...")
    from app.db.base import Base
    print("Base imported.")
    
    print("Done.")
except Exception as e:
    print(f"Error: {e}")
