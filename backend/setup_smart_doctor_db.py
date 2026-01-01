import asyncio
import os
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
if DATABASE_URL:
    if DATABASE_URL.startswith("postgresql://"):
        DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://")
    if "sslmode=require" in DATABASE_URL:
        DATABASE_URL = DATABASE_URL.replace("sslmode=require", "ssl=require")

async def setup_db():
    print(f"Connecting to database...")
    # statement_cache_size=0 is required for PgBouncer/Neon Pooler
    engine = create_async_engine(DATABASE_URL, echo=True, connect_args={"statement_cache_size": 0})
    
    # Read SQL file
    sql_files = ["smart_doctor_schema.sql", "lab_protocols.sql", "dosage_protocols.sql", "risk_rules.sql", "clinical_alerts.sql", "adverse_events.sql", "drug_interactions.sql"]
    
    async with engine.begin() as conn:
        print("Executing SQL schema...")
        for file_name in sql_files:
            sql_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "sql", file_name)
            if not os.path.exists(sql_path):
                print(f"Skipping {file_name} (not found)")
                continue

            print(f"Reading SQL from {sql_path}...")
            with open(sql_path, "r") as f:
                sql_content = f.read()

            # Split by semicolon and execute each statement
            statements = sql_content.split(';')
            for statement in statements:
                if statement.strip():
                    # print(f"Executing: {statement[:50].replace(chr(10), ' ')}...")
                    await conn.execute(text(statement))
    
    print(" [OK] Smart Doctor Tables Created & Seeded!")
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(setup_db())
