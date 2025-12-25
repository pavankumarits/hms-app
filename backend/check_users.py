from sqlalchemy import create_engine, text
from app.core.config import settings

# Force pymysql
url = settings.DATABASE_URL.replace("+aiomysql", "+pymysql")
if "+pymysql" not in url and "+aiomysql" not in settings.DATABASE_URL:
    url = url.replace("mysql://", "mysql+pymysql://")

engine = create_engine(url)

with engine.connect() as conn:
    result = conn.execute(text("SELECT username, role, hospital_id FROM users"))
    users = result.fetchall()
    print(f"Found {len(users)} users:")
    for u in users:
        print(f"User: {u.username}, Role: {u.role}")
