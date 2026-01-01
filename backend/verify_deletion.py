
import sys
import os
import pymysql

sys.path.append(os.getcwd())

try:
    from app.core.config import settings
    from sqlalchemy.engine.url import make_url

    url = make_url(settings.DATABASE_URL)
    conn = pymysql.connect(
        host=url.host,
        user=url.username,
        password=url.password,
        database=url.database,
        port=url.port or 3306
    )
    cursor = conn.cursor()
    cursor.execute("SELECT id, name FROM patients WHERE name = 'Test Patient (Sync Check)'")
    rows = cursor.fetchall()
    
    if not rows:
        print("STATUS: DELETED (Patient not found in Backend)")
    else:
        print(f"STATUS: ABORTED (Found {len(rows)} record(s) remaining)")

    conn.close()

except Exception as e:
    print(f"Error: {e}")
