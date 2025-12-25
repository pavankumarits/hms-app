import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from app.core.config import settings
from sqlalchemy.engine.url import make_url

url = settings.DATABASE_URL.replace("+aiomysql", "+pymysql")
print(f"Original URL from settings: '{settings.DATABASE_URL}'")
print(f"Modified URL for pymysql:   '{url}'")

u = make_url(url)
print(f"Parsed Password: '{u.password}'")
print(f"Parsed Host:     '{u.host}'")
print(f"Parsed Port:     {u.port}")
