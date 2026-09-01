@echo off
REM Infra Jejak — one-time project setup (Windows).
REM Run this once after unzipping, before opening in Android Studio.

echo ==^> Checking Flutter installation...
call flutter --version
IF ERRORLEVEL 1 GOTO :error

echo ==^> Generating platform folders (android\, ios\, etc.)...
call flutter create . --project-name infra_jejak
IF ERRORLEVEL 1 GOTO :error

echo ==^> Fetching packages...
call flutter pub get
IF ERRORLEVEL 1 GOTO :error

echo.
echo Done. Next steps:
echo   1. (Optional) Set up Firebase - see README.md "Setup" section.
echo   2. Open this folder in Android Studio, or run: flutter run
GOTO :eof

:error
echo Setup failed - see the error above. Make sure Flutter is installed and on PATH.
exit /b 1
