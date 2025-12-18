# Hospital Management System (HMS) - Final Architecture

**Constraint Mode**: Local-First Hosting (Laptop Server)
**Target User**: Non-Technical Staff
**Hardware**: Windows 10 Laptop (4GB RAM)

## 1. Architecture Diagram

```ascii
                                     INTERNET
                                        |
       +-------------------+            |             +-----------------------+
       |   Mobile App      |            |             |   Cloudflare Edge     |
       | (Flutter Android) | -----------------------> | (Fixed Tunnel URL)    |
       +-------------------+            |             +-----------+-----------+
                                        |                         |
       +-------------------+            |                         | Secure Tunnel
       |   Web Dashboard   |            |                         | (Encrypted)
       |  (Flutter Web)    | -------------------------------------+
       +-------------------+                                      |
                                                                  v
+-----------------------------------------------------------------------------+
|  HOSPITAL LAPTOP (Server)                                     [Windows 10]  |
|                                                                             |
|  +----------------+      +----------------+      +-----------------------+  |
|  |  Cloudflared   | ---> |  FastAPI App   | ---> |  MySQL Database       |  |
|  | (Tunnel Agent) |      | (Backend API)  |      | (Data Storage)        |  |
|  +----------------+      +----------------+      +-----------------------+  |
|                                                                             |
+-----------------------------------------------------------------------------+
```

## 2. Components & Data Flow

### A. The Server (Your Laptop)
The entire "Brain" of the system runs on your Laptop.
1.  **MySQL 8.x**: Stores all patient data securely. It does not accept connections from the internet.
2.  **FastAPI (Backend)**: Runs on port `8000`. It processes requests, checks passwords (JWT), and talks to the Database.
3.  **Cloudflare Tunnel**: A small program (`cloudflared`) that connects your local port `8000` to the internet via a secure URL (e.g., `https://hms-hospital.trycloudflare.com`).

### B. The Apps (Frontend)
1.  **Android App**: Staff carries this. It connects to the Fixed Tunnel URL.
2.  **Web Dashboard**: Viewable on any browser (Laptop, Phone, Tablet) via the same URL.
3.  **Offline Mode**:
    *   If the Internet/Tunnel is down, the App saves data to its internal **SQLite** database.
    *   It shows "Sync Pending".
    *   When connection restores, it automatically sends data to the Server.

## 3. Folder Structure (Simplified)

```
C:\HMS_Project\
├── backend\               # The Brain (Python Code)
│   ├── app\main.py        # Starts the request handler
│   ├── requirements.txt   # List of extensions needed
│   └── .env               # Passwords and Settings
│
├── frontend\              # The App Code (Flutter)
│   ├── lib\               # Source code
│   └── pubspec.yaml       # App dependencies
│
├── sql\
│   └── init_db.sql        # Database Setup Script
│
└── start_hms.bat          # DOUBLE CLICK THIS TO START EVERYTHING
```

## 4. Environment Variables (.env)
Create a file named `.env` in the `backend/` folder:

```ini
# Security
SECRET_KEY=change_this_to_a_long_random_secret_string

# Database Connection (User:Password@Host/DBName)
# Since everything is local, we use localhost.
DATABASE_URL=mysql+aiomysql://root:root@localhost:3306/hms_db

# Allowed Origins (For Web App)
BACKEND_CORS_ORIGINS=["*"]
```

## 5. Offline & Sync Logic
*   **Safety First**: Data is always saved to the phone's memory first.
*   **Auto-Retry**: If the Laptop is off, the Phone keeps trying to send data every time network changes.
*   **Conflict Prevention**: The server uses unique IDs (UUIDs) for every patient so duplicate entries are impossible, even if you click "Save" twice.
