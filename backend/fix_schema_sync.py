
import sys
import os
import pymysql
# Add current directory to path so we can import app
sys.path.append(os.getcwd())
from app.core.config import settings
from sqlalchemy.engine.url import make_url

print(f"Database URL: {settings.DATABASE_URL}")

url = make_url(settings.DATABASE_URL)
# url.password is likely populated
# url.username
# url.host
# url.database

print(f"Connecting to {url.database} on {url.host} as {url.username}...")

try:
    conn = pymysql.connect(
        host=url.host,
        user=url.username,
        password=url.password,
        database=url.database,
        port=url.port or 3306
    )
    cursor = conn.cursor()
    print("Connected.")

    # 1. Check/Add patient_uiid
    print("Checking 'patients' table...")
    try:
        cursor.execute("SELECT patient_uiid FROM patients LIMIT 1")
        print(" - 'patient_uiid' exists.")
    except Exception as e:
        print(f" - 'patient_uiid' missing. Adding...")
        cursor.execute("ALTER TABLE patients ADD COLUMN patient_uiid VARCHAR(255)")
        print(" - Added 'patient_uiid'.")

    # 2. Check/Add visits columns
    print("Checking 'visits' table...")
    columns_to_add = {
        'complaint': 'TEXT',
        'diagnosis': 'TEXT',
        'treatment': 'TEXT',
        'billing_amount': 'FLOAT DEFAULT 0.0'
    }

    for col, definition in columns_to_add.items():
        try:
            cursor.execute(f"SELECT {col} FROM visits LIMIT 1")
            print(f" - '{col}' exists.")
        except Exception as e:
            print(f" - '{col}' missing. Adding...")
            cursor.execute(f"ALTER TABLE visits ADD COLUMN {col} {definition}")
            print(f" - Added '{col}'.")
            
    conn.commit()
    conn.close()
    print("Schema update completed successfully.")

except Exception as e:
    print(f"Fatal Error: {e}")
