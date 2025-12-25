from sqlalchemy import create_engine, text
from app.core.config import settings

# Force pymysql
url = settings.DATABASE_URL.replace("+aiomysql", "+pymysql")
if "+pymysql" not in url and "+aiomysql" not in settings.DATABASE_URL:
    url = url.replace("mysql://", "mysql+pymysql://")

engine = create_engine(url)

print(f"Resetting DB at {url}...")

with engine.connect() as conn:
    try:
        conn.execute(text("DELETE FROM users"))
    except: pass
    try:
        conn.execute(text("DELETE FROM hospitals"))
    except: pass
    conn.commit()
    print("Database reset complete.")
