@echo off
setlocal

echo Checking JAVA_HOME...
echo Current JAVA_HOME: "%JAVA_HOME%"

:: Check if JAVA_HOME ends with \bin and strip it if so
if "%JAVA_HOME:~-4%"=="\bin" (
    echo JAVA_HOME points to bin directory. attempting to fix...
    set "JAVA_HOME=%JAVA_HOME:~0,-4%"
)

:: Check if the corrected/current JAVA_HOME exists
if exist "%JAVA_HOME%\bin\java.exe" (
    echo Valid Java found at: %JAVA_HOME%
    goto :RunBuild
)

echo invalid JAVA_HOME. Searching for valid JDK...

:: Try common locations
if exist "C:\Program Files\Java\jdk-17\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Java\jdk-17"
    goto :FoundJava
)
if exist "C:\Program Files\Android\Android Studio\jbr\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
    goto :FoundJava
)
if exist "C:\Program Files\Java\jdk-11\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Java\jdk-11"
    goto :FoundJava
)

:: If we can't find specific ones, try to find ANY jdk folder in Program Files
for /d %%i in ("C:\Program Files\Java\jdk*") do (
    if exist "%%i\bin\java.exe" (
        set "JAVA_HOME=%%i"
        goto :FoundJava
    )
)

echo Could not find a specific JDK in Program Files.
echo Checking if java is available in PATH...
where java >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Java is available in PATH. Unsetting JAVA_HOME to rely on PATH.
    set "JAVA_HOME="
    goto :RunBuild
)

echo ERROR: Could not find a valid JDK. Please install JDK 11 or 17.
exit /b 1

:FoundJava
echo Found Java at: %JAVA_HOME%

:RunBuild
if defined JAVA_HOME (
    echo Setting JAVA_HOME to: %JAVA_HOME%
    set "JAVA_HOME=%JAVA_HOME%"
) else (
    echo JAVA_HOME is unset. Using Java from PATH.
)

echo.
echo Running Flutter Doctor...
call flutter doctor -v

echo.
echo Cleaning Gradle...
call gradlew.bat clean

echo.
echo Building Debug APK...
call gradlew.bat assembleDebug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo BUILD SUCCESSFUL!
    echo Your environment is working (using PATH or discovered JAVA_HOME).
) else (
    echo.
    echo BUILD FAILED. Please check the logs above.
)

endlocal
