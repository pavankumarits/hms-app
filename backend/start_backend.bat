@echo off
echo ========================================
echo Starting HMS Backend Server
echo ========================================
echo.
echo Backend will run on: http://localhost:8000
echo API documentation: http://localhost:8000/docs
echo.
echo Make sure to run start_tunnel.bat in another window
echo to expose the backend via ngrok!
echo.
cd /d "%~dp0"
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
