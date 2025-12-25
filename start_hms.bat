@echo off
TITLE Hospital Management System - Server
COLOR 0A

echo ====================================================
echo      HOSPITAL MANAGEMENT SYSTEM (HMS)
echo      Server Startup Script
echo ====================================================
echo.

:: 1. Check MySQL Service
echo [1/3] Checking Database...
sc query MySQL80 | find "RUNNING"
IF %ERRORLEVEL% NEQ 0 (
   echo WARNING: MySQL Service is not running!
   echo Attempting to start...
   net start MySQL80
) ELSE (
   echo Database is Active.
)

:: 2. Activate Python Environment and Start Backend
echo.
echo [2/3] Starting Backend API...
cd backend
IF NOT EXIST "venv" (
   echo ERROR: Virtual Environment not found! Please run setup instructions.
   pause
   exit
)
call venv\Scripts\activate

:: Start Uvicorn in background? No, keep it visible for logs.
:: We use 'start' to spawn separate windows.

start "HMS Backend" cmd /k "venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload"

echo Waiting 20 seconds for Backend to initialize...
timeout /t 20

start "HMS Public Tunnel" cmd /k "cloudflared.exe tunnel --url http://127.0.0.1:8000"

echo.
echo ====================================================
echo SYSTEM IS RUNNING.
echo 1. Keep these windows OPEN.
echo 2. Check the 'HMS Public Tunnel' window for your URL.
echo 3. Share that URL with the App users.
echo ====================================================
pause
