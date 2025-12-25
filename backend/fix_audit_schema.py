import sys
import os

# Add the parent directory to sys.path so we can import 'app'
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from sqlalchemy import create_engine, text
from app.core.config import settings

# Force pymysql
url = settings.DATABASE_URL.replace("+aiomysql", "+pymysql")
if "+pymysql" not in url and "+aiomysql" not in settings.DATABASE_URL:
    url = url.replace("mysql://", "mysql+pymysql://")

print(f"Connecting to DB...") 

engine = create_engine(url)

with engine.connect() as conn:
    print("Checking 'audit_logs' table...")
    try:
        # Check if column exists
        result = conn.execute(text("SHOW COLUMNS FROM audit_logs LIKE 'resource'"))
        if result.fetchone():
            print("Column 'resource' already exists.")
        else:
            print("Adding missing column 'resource'...")
            conn.execute(text("ALTER TABLE audit_logs ADD COLUMN resource VARCHAR(50)"))
            conn.commit()
            print("Column 'resource' added successfully.")
    except Exception as e:
        print(f"Error: {e}")
