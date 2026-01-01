
import os
import signal
import subprocess
import pymysql
import sys
from app.core.config import settings
from sqlalchemy.engine.url import make_url

def kill_port_8000():
    try:
        # Find PID on port 8000
        cmd = "netstat -ano | findstr :8000"
        result = subprocess.check_output(cmd, shell=True).decode()
        for line in result.splitlines():
            parts = line.split()
            if len(parts) > 4:
                pid = int(parts[-1])
                print(f"Killing PID {pid} on port 8000...")
                os.kill(pid, signal.SIGTERM) # Or SIGKILL
                # Windows might need:
                subprocess.call(['taskkill', '/F', '/T', '/PID', str(pid)])
                
    except subprocess.CalledProcessError:
        print("No process found on port 8000.")
    except Exception as e:
        print(f"Error killing process: {e}")

def clean_data():
    try:
        url = make_url(settings.DATABASE_URL.replace("+aiomysql", "+pymysql"))
        conn = pymysql.connect(
            host=url.host,
            user=url.username,
            password=url.password,
            database=url.database,
            port=url.port or 3306
        )
        cursor = conn.cursor()
        print("Deleting Test Patients...")
        cursor.execute("DELETE FROM patients WHERE name LIKE 'Test Patient%'")
        conn.commit()
        print(f"Deleted {cursor.rowcount} rows.")
        conn.close()
    except Exception as e:
        print(f"DB Error: {e}")

if __name__ == "__main__":
    kill_port_8000()
    clean_data()
