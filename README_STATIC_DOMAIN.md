# Static ngrok Domain Setup

## Your Static Domain
**Domain:** `nonenunciative-jadon-deucedly.ngrok-free.dev`

This is your **permanent free dev domain** from ngrok. It will never change!

## How to Use

### 1. Start the Backend Server
```bash
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Or simply run:
```bash
.\backend\start_backend.bat
```

### 2. Start the ngrok Tunnel (in a new terminal)
```bash
ngrok http --domain=nonenunciative-jadon-deucedly.ngrok-free.dev 8000
```
Or simply run:
```bash
.\backend\start_tunnel.bat
```

### 3. Your Backend is Now Live!
Your backend will be accessible at:
**https://nonenunciative-jadon-deucedly.ngrok-free.dev**

## Flutter App Configuration
The Flutter app is already configured to use this static domain in:
- `frontend/lib/core/config.dart`

No need to change URLs anymore! 🎉

## Benefits
✅ **Permanent URL** - Never changes  
✅ **No need to update the app** - URL is hardcoded  
✅ **Free tier** - No cost  
✅ **Easy development** - Same URL every time  

## Important Notes
- You must run ngrok with the `--domain` flag to use your static domain
- The free tier allows 1 static domain per account
- Make sure your backend is running on port 8000 before starting the tunnel
- Both backend and tunnel must be running for the app to work
