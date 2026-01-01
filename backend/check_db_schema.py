
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
    result = conn.execute(text("SHOW CREATE TABLE patients"))
    row = result.fetchone()
    print(row[1])
