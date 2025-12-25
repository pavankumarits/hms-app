import sys
import os

# Add the parent directory to sys.path so we can import 'app'
# This assumes the script is run from the 'backend' directory or project root
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from sqlalchemy import create_engine, text
from app.core.config import settings
from app.core.security import get_password_hash

# Force pymysql
url = settings.DATABASE_URL.replace("+aiomysql", "+pymysql")
if "+pymysql" not in url and "+aiomysql" not in settings.DATABASE_URL:
    url = url.replace("mysql://", "mysql+pymysql://")

print(f"Connecting to: {url.split('@')[1]}") # Hide password in log

engine = create_engine(url)

username = "admin"
new_password = "pass111"
hashed_pwd = get_password_hash(new_password)

with engine.connect() as conn:
    # Check if user exists
    result = conn.execute(text("SELECT id, username FROM users WHERE username = :username"), {"username": username})
    user = result.fetchone()
    
    if user:
        print(f"User {username} found (ID: {user.id}). Updating password...")
        conn.execute(
            text("UPDATE users SET hashed_password = :pwd WHERE id = :id"),
            {"pwd": hashed_pwd, "id": user.id}
        )
        conn.commit()
        print("Password updated successfully.")
    else:
        print(f"User {username} NOT found.")
