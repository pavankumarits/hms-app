@echo off
TITLE HMS - Database Setup (Phase 2)
COLOR 0B

echo ====================================================
echo      HMS DATABASE SETUP ASSISTANT
echo ====================================================
echo.
echo This script will create the database structure for you.
echo You will be asked for your MySQL 'root' password.
echo.

:: Check if mysql is in PATH
where mysql >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: MySQL is not found in your PATH.
    echo Please reinstall MySQL and check "Add to PATH", or restart your PC.
    pause
    exit
)

echo [1/1] Importing Database Schema...
echo Please enter your MySQL password below:
mysql -u root -p < sql/init_db.sql

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Database setup failed. Check your password.
    pause
    exit
)

echo.
echo ====================================================
echo SUCCESS! Database 'hms_db' is ready.
echo You can now proceed to Phase 3 (Install Server).
echo ====================================================
pause
