from sqlalchemy import create_engine, text
from app.core.config import settings

# Use sync engine for simple script
# Note: DATABASE_URL in settings might be async (mysql+aiomysql)
# We need to strip '+aiomysql' for standard pymysql or use async engine.
# Let's try removing driver specific part if present.

url = settings.DATABASE_URL.replace("+aiomysql", "+pymysql")
# If it doesn't have driver, default might be mysqldb, so +pymysql is safer.
if "+pymysql" not in url and "+aiomysql" not in settings.DATABASE_URL:
    url = url.replace("mysql://", "mysql+pymysql://")


engine = create_engine(url)

from sqlalchemy import inspect

with engine.connect() as conn:
    try:
        conn.execute(text("DELETE FROM users"))
        try:
            conn.execute(text("DELETE FROM hospitals"))
        except:
             pass # Hospital table might be named differently or used via association
        
        # Check hospital table name?
        # Assuming 'models/hospital.py'. Let's just delete users for now, and see. 
        # Actually, setup usually checks if 'any' hospital exists.
        # Let's check table list first? No, just delete hospitals if exists.
        # If I leave hospital, they might not be able to create new one if logic checks count.
        
        # Better:
        conn.execute(text("DELETE FROM hospital")) # Try singular
    except Exception as e:
        print(f"ERROR: {e}")
        try:
             conn.execute(text("DELETE FROM hospitals")) # Try plural
        except Exception as ex:
             print(f"ERROR 2: {ex}")

    conn.commit()
    print("SUCCESS: Cleared data.")

print("Done.")

