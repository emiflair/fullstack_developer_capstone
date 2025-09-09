@echo off
REM Startup script for Car Dealership Web Application (Windows)
REM This script starts all required services

echo 🚗 Starting Car Dealership Web Application...

REM Check if we're in the right directory
if not exist "server\manage.py" (
    echo ❌ Error: Please run this script from the project root directory
    pause
    exit /b 1
)

echo 🔍 Checking setup...

REM Create Python virtual environment if it doesn't exist
if not exist ".venv" (
    if not exist "server\.venv" (
        echo 🐍 Creating Python virtual environment...
        cd server
        python -m venv ..\.venv
        cd ..
    )
)

REM Activate virtual environment
echo 🐍 Activating Python virtual environment...
if exist ".venv\Scripts\activate.bat" (
    call .venv\Scripts\activate.bat
) else if exist "server\.venv\Scripts\activate.bat" (
    call server\.venv\Scripts\activate.bat
) else (
    echo ❌ Virtual environment not found
    pause
    exit /b 1
)

REM Install Python dependencies
echo 📦 Installing Python dependencies...
cd server
pip install -q -r requirements.txt

REM Run Django migrations
echo 🗃️ Running Django migrations...
python manage.py migrate

REM Install Node.js dependencies for database API
echo 📦 Installing Node.js dependencies...
cd database
call npm install --silent

REM Build React frontend
echo ⚛️ Building React frontend...
cd ..\frontend
call npm install --silent
set GENERATE_SOURCEMAP=false
call npm run build

REM Go back to server directory
cd ..

echo 🎉 Setup complete! Starting services...

REM Start database API in background
echo 🚀 Starting Database API (Port 3030)...
cd database
start /B node app.js
cd ..

REM Wait a moment for database to start
timeout /t 2 /nobreak >nul

REM Start Django server
echo 🚀 Starting Django Server (Port 8000)...
echo 📱 Application will be available at: http://localhost:8000
echo.
echo 🛑 Press Ctrl+C to stop all services
echo.

REM Start Django (this will run in foreground)
python manage.py runserver 0.0.0.0:8000

echo ✅ Django server stopped
pause
