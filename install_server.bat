@echo off
TITLE HMS - Server Installation (Phase 3)
COLOR 0E

echo ====================================================
echo      HMS SERVER INSTALLER
echo ====================================================
echo.

:: Check if python is in PATH
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Python is not found.
    echo Please install Python 3.10+ and check "Add to PATH".
    pause
    exit
)

echo [1/3] Creating Python Virtual Environment (Isolation)...
cd backend
python -m venv venv

echo.
echo [2/3] Activating Environment...
call venv\Scripts\activate

echo.
echo [3/3] Installing Dependencies (This may take a minute)...
pip install -r requirements.txt

echo.
echo [4/4] Creating Environment Config (.env)...
if not exist .env (
    echo SECRET_KEY=hms_secret_key_123456 > .env
    echo DATABASE_URL=mysql+aiomysql://root:2349@localhost:3306/hms_db >> .env
    echo BACKEND_CORS_ORIGINS=["*"] >> .env
    echo Config file created.
) else (
    echo Config file already exists. Overwriting to ensure correct password...
    echo SECRET_KEY=hms_secret_key_123456 > .env
    echo DATABASE_URL=mysql+aiomysql://root:2349@localhost:3306/hms_db >> .env
    echo BACKEND_CORS_ORIGINS=["*"] >> .env
)

echo.
echo ====================================================
echo SUCCESS! Server is installed.
echo You can now run 'start_hms.bat' anytime to use the app.
echo ====================================================
pause
