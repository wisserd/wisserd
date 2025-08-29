@echo off
REM ====================================
REM Fix Windsurf PATH + Test Node.js Env
REM ====================================

echo Checking Node.js installation...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo Node.js not found! Installing Node.js is required.
    exit /b 1
) else (
    echo Node.js is installed: 
    node -v
)

echo.
echo Checking Windsurf installation...
where windsurf >nul 2>nul
if %errorlevel% neq 0 (
    echo Windsurf not found in PATH. Attempting to add default install path...
    setx PATH "%PATH%;C:\Windsurf"
    echo PATH updated. Please restart your terminal.
) else (
    echo Windsurf is installed: 
    windsurf --version
)

echo.
echo Installing dependencies...
if exist package.json (
    npm install
) else (
    echo No package.json found! Make sure you are in your project folder.
)

echo.
echo Starting Windsurf...
windsurf dev

pause
