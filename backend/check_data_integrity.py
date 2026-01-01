
import sys
import os
from sqlalchemy import create_engine, text
from app.core.config import settings

# Force pymysql
url = settings.DATABASE_URL.replace("+aiomysql", "+pymysql")
if "+pymysql" not in url and "+aiomysql" not in settings.DATABASE_URL:
    url = url.replace("mysql://", "mysql+pymysql://")

engine = create_engine(url)

with engine.connect() as conn:
    print("Users:")
    users = conn.execute(text("SELECT id, username, hospital_id FROM users")).fetchall()
    for u in users:
        print(f"User: {u.username}, Hosp: {u.hospital_id}")
        
    print("\nHospitals:")
    hosps = conn.execute(text("SELECT id, name FROM hospitals")).fetchall()
    for h in hosps:
        print(f"Hosp: {h.id}, Name: {h.name}")
        
    # Check FK validity
    valid_ids = [h.id for h in hosps]
    for u in users:
        if u.hospital_id not in valid_ids:
            print(f"CRITICAL: User {u.username} has invalid hospital_id {u.hospital_id}")
