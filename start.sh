#!/bin/bash

# Startup script for Car Dealership Web Application
# This script starts all required services

echo "🚗 Starting Car Dealership Web Application..."

# Check if we're in the right directory
if [ ! -f "server/manage.py" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Function to check if port is in use (graceful fallback)
check_port() {
    if command -v lsof >/dev/null 2>&1; then
        if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "⚠️  Port $1 is already in use"
            return 1
        fi
    elif command -v netstat >/dev/null 2>&1; then
        if netstat -an | grep ":$1.*LISTEN" >/dev/null 2>&1; then
            echo "⚠️  Port $1 is already in use"
            return 1
        fi
    else
        echo "ℹ️  Skipping port check (lsof/netstat not available)"
    fi
    return 0
}

# Check ports
echo "🔍 Checking ports..."
check_port 8000 || echo "Django might already be running on port 8000"
check_port 3030 || echo "Database API might already be running on port 3030"

# Create Python virtual environment if it doesn't exist
if [ ! -d "server/.venv" ] && [ ! -d ".venv" ]; then
    echo "🐍 Creating Python virtual environment..."
    cd server
    python3 -m venv ../.venv
    cd ..
fi

# Activate virtual environment
echo "🐍 Activating Python virtual environment..."
if [ -d ".venv" ]; then
    source .venv/bin/activate
elif [ -d "server/.venv" ]; then
    source server/.venv/bin/activate
else
    echo "❌ Virtual environment not found"
    exit 1
fi

# Install Python dependencies
echo "📦 Installing Python dependencies..."
cd server
pip install -q -r requirements.txt

# Run Django migrations
echo "🗃️  Running Django migrations..."
python3 manage.py migrate

# Install Node.js dependencies for database API
echo "📦 Installing Node.js dependencies..."
cd database
npm install --silent

# Build React frontend
echo "⚛️  Building React frontend..."
cd ../frontend
npm install --silent
GENERATE_SOURCEMAP=false npm run build

# Go back to server directory
cd ..

echo "🎉 Setup complete! Starting services..."

# Start database API in background
echo "🚀 Starting Database API (Port 3030)..."
cd database
node app.js &
DATABASE_PID=$!
cd ..

# Wait a moment for database to start
sleep 2

# Start Django server
echo "🚀 Starting Django Server (Port 8000)..."
echo "📱 Application will be available at: http://localhost:8000"
echo ""
echo "🛑 Press Ctrl+C to stop all services"
echo ""

# Trap Ctrl+C to kill background processes
trap 'echo ""; echo "🛑 Stopping services..."; kill $DATABASE_PID 2>/dev/null; exit' INT

# Start Django (this will run in foreground)
python3 manage.py runserver 0.0.0.0:8000

# If we get here, Django stopped, so clean up
kill $DATABASE_PID 2>/dev/null
echo "✅ All services stopped"
