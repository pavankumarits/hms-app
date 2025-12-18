@echo off
SETLOCAL EnableDelayedExpansion
echo ==================================================
echo       FORCE RESTARTING FLUTTER FRONTEND
echo ==================================================
echo.
echo [1/5] Killing any stuck Dart/Flutter processes...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
echo Done.
echo.

echo [2/5] Navigating to frontend...
cd /d "%~dp0frontend"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Could not find frontend directory.
    pause
    exit /b
)
echo Current dir: %CD%
echo.

echo [3/5] Cleaning build cache (SKIPPED for speed)...
echo (Uncomment the lines in the script if you really need to clean)
REM call flutter clean
REM if %ERRORLEVEL% NEQ 0 (
REM     echo WARNING: 'flutter clean' failed. Proceeding anyway...
REM )
echo Done.
echo Done.
echo.

echo [4/5] resolving dependencies (SKIPPED for speed)...
REM call flutter pub get
REM if %ERRORLEVEL% NEQ 0 (
REM     echo ERROR: 'flutter pub get' failed. Check your internet connection.
REM     pause
REM     exit /b
REM )
echo Done.
echo.

echo [5/5] Launching Web App...
echo ==================================================
echo PLEASE WAIT!
echo Converting icons and compiling code can take 1-2 minutes.
echo A Chrome window should open automatically.
echo ==================================================
echo.
call flutter run -d chrome -v
echo.
echo Application exited.
pause
