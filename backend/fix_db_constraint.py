
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
    print("Applying Unique Constraint...")
    try:
        conn.execute(text("ALTER TABLE patients ADD CONSTRAINT uq_hospital_patient_uiid UNIQUE (hospital_id, patient_uiid)"))
        print("Constraint Applied.")
    except Exception as e:
        print(f"Error (might exist): {e}")
    conn.commit()
