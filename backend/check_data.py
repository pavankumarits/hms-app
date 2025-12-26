
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
    
    cursor.execute("SELECT COUNT(*) FROM patients")
    p_count = cursor.fetchone()[0]
    print(f"Total Patients: {p_count}")
    
    cursor.execute("SELECT COUNT(*) FROM visits")
    v_count = cursor.fetchone()[0]
    print(f"Total Visits: {v_count}")
    
    if count > 0:
        cursor.execute("SELECT id, name, patient_uiid FROM patients LIMIT 5")
        rows = cursor.fetchall()
        print("Sample Data:")
        for row in rows:
            print(row)
    
    conn.close()

except Exception as e:
    print(f"Error: {e}")
