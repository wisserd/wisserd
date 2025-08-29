@echo off
REM ============================
REM Windsurf One-Time Fix Script
REM ============================

echo Checking Node.js...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed! Please install Node.js (https://nodejs.org) first.
    pause
    exit /b 1
)

echo Node.js found: 
node -v

echo.
echo Checking Windsurf...
where windsurf >nul 2>nul
if %errorlevel% neq 0 (
    echo Windsurf not found. Installing globally...
    npm install -g windsurf
) else (
    echo Windsurf found:
    windsurf --version
)

echo.
echo Installing project dependencies...
if exist package.json (
    npm install
) else (
    echo ERROR: No package.json found. Run this script in your project folder.
    pause
    exit /b 1
)

echo.
echo Starting Windsurf Dev Server...
windsurf dev

pause
