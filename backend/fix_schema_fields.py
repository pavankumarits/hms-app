
import sys
import os
import pymysql
import datetime

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
    print("Connected.")

    # 1. Add dob if missing
    print("Checking 'dob' in 'patients'...")
    try:
        cursor.execute("SELECT dob FROM patients LIMIT 1")
        print(" - 'dob' exists.")
    except Exception:
        print(" - 'dob' missing. Adding column...")
        cursor.execute("ALTER TABLE patients ADD COLUMN dob DATE DEFAULT '2000-01-01'")
        
        # Migrate age to dob (approx)
        print(" - Migrating age to dob...")
        try:
            cursor.execute("SELECT id, age FROM patients WHERE age IS NOT NULL")
            rows = cursor.fetchall()
            for pid, age in rows:
                approx_year = datetime.datetime.now().year - age
                dob_str = f"{approx_year}-01-01"
                cursor.execute("UPDATE patients SET dob=%s WHERE id=%s", (dob_str, pid))
            print(f" - Migrated {len(rows)} records.")
        except Exception as e:
            print(f" - Auto-migration failed: {e}")

    # 2. Add phone if missing
    print("Checking 'phone' in 'patients'...")
    try:
        cursor.execute("SELECT phone FROM patients LIMIT 1")
        print(" - 'phone' exists.")
    except Exception:
        print(" - 'phone' missing. Adding column...")
        cursor.execute("ALTER TABLE patients ADD COLUMN phone VARCHAR(20) DEFAULT NULL")
        
        # Migrate contact_number to phone
        print(" - Migrating contact_number to phone...")
        try:
            cursor.execute("UPDATE patients SET phone = contact_number WHERE contact_number IS NOT NULL")
            print(" - Data migrated.")
        except Exception as e:
            print(f" - Migration failed: {e}")

    conn.commit()
    conn.close()
    print("Schema alignment completed.")

except Exception as e:
    print(f"Fatal Error: {e}")
