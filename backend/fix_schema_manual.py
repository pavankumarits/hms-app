
import asyncio
from app.db.session import AsyncSessionLocal
from sqlalchemy import text

async def fix_schema():
    async with AsyncSessionLocal() as session:
        print("Checking Patients table...")
        try:
            # Check if patient_uiid exists
            await session.execute(text("SELECT patient_uiid FROM patients LIMIT 1"))
            print("Patients table OK.")
        except Exception:
            print("Adding patient_uiid to patients...")
            try:
                await session.execute(text("ALTER TABLE patients ADD COLUMN patient_uiid VARCHAR(255)"))
                await session.commit()
                print("Added patient_uiid.")
            except Exception as e:
                print(f"Error adding patient_uiid: {e}")

        print("Checking Visits table...")
        try:
            # Check if complaint, diagnosis, treatment, billing_amount exist
            await session.execute(text("SELECT complaint FROM visits LIMIT 1"))
            print("Visits table OK.")
        except Exception:
            print("Adding columns to visits...")
            try:
                await session.execute(text("ALTER TABLE visits ADD COLUMN complaint TEXT"))
                await session.execute(text("ALTER TABLE visits ADD COLUMN diagnosis TEXT"))
                await session.execute(text("ALTER TABLE visits ADD COLUMN treatment TEXT"))
                await session.execute(text("ALTER TABLE visits ADD COLUMN billing_amount FLOAT DEFAULT 0.0"))
                await session.commit()
                print("Added missing columns to visits.")
            except Exception as e:
                print(f"Error adding visits columns: {e}")

if __name__ == "__main__":
    asyncio.run(fix_schema())
