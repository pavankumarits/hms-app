# HMS Deployment Guide (Non-Technical)

Follow these steps exactly to set up your Hospital System.
**Constraint**: Everything runs on your Windows Laptop.

## Phase 1: Install Required Software
1.  **Python 3.10+**: Download from [python.org](https://www.python.org/downloads/).
    *   *Important*: Check the box **"Add Python to PATH"** during installation.
2.  **MySQL Server 8.x**: Download "MySQL Installer Community" from [mysql.com](https://dev.mysql.com/downloads/installer/).
    *   Select "Server Only".
    *   Set Root Password to `root` (or remember what you pick).
3.  **Git**: Download from [git-scm.com](https://git-scm.com/download/win).
4.  **Cloudflared**: Download the Windows executable from [Cloudflare](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/).
    *   Rename it to `cloudflared.exe` and place it in `C:\Windows\System32` (or anywhere in PATH).

## Phase 2: Setup the Database
1.  **Double Click** `setup_db.bat`.
2.  Enter your MySQL root password when prompted.
3.  Wait for the "SUCCESS" message.

## Phase 3: Setup the Backend (The Server)
1.  **Double Click** `install_server.bat`.
2.  Wait for it to download and install all necessary tools.
3.  It will create the settings file (`.env`) automatically.
4.  Wait for the "SUCCESS" message.

## Phase 4: Generate the Mobile App (Cloud Build)
*You don't need to install Android tools.*
1.  Upload this entire project folder to **GitHub**.
2.  Go to the **"Actions"** tab in your GitHub repository.
3.  You will see "Build Flutter APK". Click it -> **Run workflow**.
4.  Wait 5-10 minutes.
5.  Click the completed run, scroll down to **Artifacts**, and download `app-release.apk`.
6.  Install this APK on your staff's Android phones.

## Phase 5: Start the System (Daily Routine)
I have created a `start_hms.bat` file for you.
1.  **Double Click** `start_hms.bat`.
2.  It will open a black window (Terminal). **DO NOT CLOSE IT**.
3.  It will verify access and show you your **Tunnel URL**.
4.  Copy this URL (e.g., `https://funny-name.trycloudflare.com`).
6.  **Setup Hospital (First Launch)**:
    *   The App will show the **Hospital Setup Screen**.
    *   Enter **Hospital Name** (e.g., "City Hospital").
    *   Enter **Tunnel URL** (from step 4).
    *   Create an **Admin Username/Password** and a **PIN** (e.g., 1234).
    *   Click **"INITIALIZE SYSTEM"**.
7.  Success! You will be redirected to the Login Screen.
8.  **To Change Hospital**: Use the Settings icon (Top Right) on Login Screen + PIN.

## Troubleshooting
*   **"Backend not connected"**: Check if the black window is open.
*   **"Database error"**: Ensure MySQL Service is running in Windows Services.
*   **"Sync Failed"**: Check internet connection on the phone.

