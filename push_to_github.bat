@echo off
set GIT_PATH="C:\Program Files\Git\cmd\git.exe"

echo Initializing Git...
%GIT_PATH% init 2>&1
if %errorlevel% neq 0 echo Git init failed & exit /b %errorlevel%

echo Adding files...
%GIT_PATH% add . 2>&1
if %errorlevel% neq 0 echo Git add failed & exit /b %errorlevel%

echo Committing...
%GIT_PATH% commit -m "Initial commit" 2>&1
if %errorlevel% neq 0 echo Git commit failed & exit /b %errorlevel%

echo Renaming branch to main...
%GIT_PATH% branch -M main 2>&1
if %errorlevel% neq 0 echo Git branch failed & exit /b %errorlevel%

echo Configuring remote...
%GIT_PATH% remote remove origin 2>nul
%GIT_PATH% remote add origin https://github.com/pavankumarits/hms-app.git 2>&1
if %errorlevel% neq 0 echo Git remote failed & exit /b %errorlevel%

echo Pushing to GitHub...
%GIT_PATH% push -u origin main 2>&1
if %errorlevel% neq 0 echo Git push failed & exit /b %errorlevel%

echo Done.
