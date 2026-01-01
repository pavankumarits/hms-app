@echo off
echo ========================================
echo Starting ngrok tunnel with static domain
echo ========================================
echo.
echo Your static domain: nonenunciative-jadon-deucedly.ngrok-free.dev
echo Backend will be available at: https://nonenunciative-jadon-deucedly.ngrok-free.dev
echo.
echo Starting tunnel...
ngrok http --domain=nonenunciative-jadon-deucedly.ngrok-free.dev 8000
