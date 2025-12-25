import sys
import os
import uuid

# Add the parent directory to sys.path so we can import 'app'
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from sqlalchemy import create_engine, text
from app.core.config import settings
from app.core.security import get_password_hash

# Force pymysql
url = settings.DATABASE_URL.replace("+aiomysql", "+pymysql")
if "+pymysql" not in url and "+aiomysql" not in settings.DATABASE_URL:
    url = url.replace("mysql://", "mysql+pymysql://")

print(f"Connecting to DB...") 

engine = create_engine(url)

target_user = "admin"
target_pwd = "pass111"
target_hash = get_password_hash(target_pwd)

with engine.connect() as conn:
    # 1. Check if user exists
    result = conn.execute(text("SELECT id, hospital_id FROM users WHERE username = :u"), {"u": target_user})
    existing = result.fetchone()
    
    if existing:
        print(f"User '{target_user}' exists. Updating password...")
        conn.execute(
            text("UPDATE users SET hashed_password = :p, is_active=1 WHERE id = :id"),
            {"p": target_hash, "id": existing.id}
        )
        conn.commit()
        print("Password updated.")
    else:
        print(f"User '{target_user}' NOT found. Creating...")
        # Get a hospital_id from existing users or create new
        res_hosp = conn.execute(text("SELECT hospital_id FROM users LIMIT 1"))
        hosp_row = res_hosp.fetchone()
        
        if hosp_row:
            hosp_id = hosp_row.hospital_id
            print(f"Using existing hospital_id: {hosp_id}")
        else:
            hosp_id = str(uuid.uuid4())
            print(f"Generated new hospital_id: {hosp_id}")
            
        new_id = str(uuid.uuid4())
        
        conn.execute(
            text("""
                INSERT INTO users (id, hospital_id, username, hashed_password, role, is_active)
                VALUES (:id, :hid, :u, :p, 'admin', 1)
            """),
            {"id": new_id, "hid": hosp_id, "u": target_user, "p": target_hash}
        )
        conn.commit()
        print(f"User '{target_user}' created successfully.")
