
import sys
import os
import pymysql
import uuid
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
    
    # Check if we already have patients
    cursor.execute("SELECT COUNT(*) FROM patients")
    count = cursor.fetchone()[0]
    
    if count == 0:
        print("Adding Test Patient...")
        p_id = str(uuid.uuid4())
        uiid = f"TEST-{datetime.datetime.now().year}-001"
        name = "Test Patient (Sync Check)"
        gender = "Male"
        age = 30
        contact = "1234567890"
        address = "123 Test St"
        # Hospital ID seems required (NO default), let's fetch one or use a dummy.
        # Check first hospital
        cursor.execute("SELECT id FROM hospitals LIMIT 1")
        h_row = cursor.fetchone()
        hospital_id = h_row[0] if h_row else "HOSP-001" 
        
        created = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        updated = created
        sync_status = "synced"
        
        sql = """
        INSERT INTO patients (id, hospital_id, patient_uiid, name, gender, age, contact_number, address, created_at, updated_at, sync_status)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(sql, (p_id, hospital_id, uiid, name, gender, age, contact, address, created, updated, sync_status))
        conn.commit()
        print(f"Successfully added {name}")
    else:
        print(f"DB already has {count} patients. Skipping test data.")
        
    conn.close()

except Exception as e:
    print(f"Error: {e}")
