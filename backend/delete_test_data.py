
import sys
import os
import pymysql

# Add current directory to path so we can import app
sys.path.append(os.getcwd())

try:
    from app.core.config import settings
    from sqlalchemy.engine.url import make_url

    print(f"Database URL: {settings.DATABASE_URL}")
    url = make_url(settings.DATABASE_URL)

    conn = pymysql.connect(
        host=url.host,
        user=url.username,
        password=url.password,
        database=url.database,
        port=url.port or 3306
    )
    cursor = conn.cursor()
    
    # Check if patient exists
    cursor.execute("SELECT id, name FROM patients WHERE name = 'Test Patient (Sync Check)'")
    rows = cursor.fetchall()
    
    if not rows:
        print("Test Patient not found.")
    else:
        print(f"Found {len(rows)} record(s). Deleting...")
        for row in rows:
            print(f"Deleting ID: {row[0]}, Name: {row[1]}")
            cursor.execute("DELETE FROM patients WHERE id = %s", (row[0],))
        
        conn.commit()
        print("Deletion Complete.")

    conn.close()

except Exception as e:
    print(f"Error: {e}")
