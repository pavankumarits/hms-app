@echo off
SETLOCAL EnableDelayedExpansion
echo ==================================================
echo       FAST LAUNCH: FLUTTER FRONTEND
echo ==================================================
echo.
echo [1/2] Navigating to frontend...
cd /d "%~dp0frontend"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Could not find frontend directory.
    pause
    exit /b
)
echo Done.
echo.

echo [2/2] Launching Web App (Fast Mode)...
echo ==================================================
echo Skipping 'flutter clean' and 'pub get' for speed.
echo If you have errors, run 'run_frontend_debug.bat' or 'flutter clean' manually.
echo.
echo A Chrome window should open shortly...
echo ==================================================
echo.
call flutter run -d chrome -v
echo.
echo Application exited.
pause
