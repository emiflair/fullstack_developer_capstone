#!/bin/bash

# Cloud-optimized startup script for Car Dealership Web Application
# This script is specifically designed for cloud environments like IBM Skills Network

echo "🌩️  Starting Car Dealership Web Application (Cloud Mode)..."

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

# Function to wait for a service to be ready
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for $service_name to be ready on port $port..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s "http://localhost:$port" > /dev/null 2>&1; then
            echo "✅ $service_name is ready!"
            return 0
        fi
        echo "   Attempt $attempt/$max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo "❌ $service_name failed to start after $max_attempts attempts"
    return 1
}

# Check ports
echo "🔍 Checking ports..."
check_port 8000 && check_port 3030

# Create Python virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "🐍 Creating Python virtual environment..."
    python3 -m venv .venv
    if [ $? -ne 0 ]; then
        echo "❌ Failed to create virtual environment"
        exit 1
    fi
fi

# Activate virtual environment
echo "🐍 Activating Python virtual environment..."
source .venv/bin/activate
if [ $? -ne 0 ]; then
    echo "❌ Failed to activate virtual environment"
    exit 1
fi

# Verify Python environment
echo "🔧 Verifying Python environment..."
which python3
python3 --version
which pip

# Install Python dependencies with verbose output for debugging
echo "📦 Installing Python dependencies..."
cd server
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "❌ Failed to install Python dependencies"
    exit 1
fi

# Verify Django installation
echo "🔧 Verifying Django installation..."
python3 -c "import django; print(f'Django version: {django.get_version()}')"
if [ $? -ne 0 ]; then
    echo "❌ Django not properly installed"
    exit 1
fi

# Run Django migrations
echo "🗃️  Running Django migrations..."
python3 manage.py migrate
if [ $? -ne 0 ]; then
    echo "❌ Django migrations failed"
    exit 1
fi

# Install Node.js dependencies for database API
echo "📦 Installing Node.js dependencies..."
cd database
npm install
if [ $? -ne 0 ]; then
    echo "❌ Failed to install Node.js dependencies"
    exit 1
fi

# Build React frontend
echo "⚛️  Building React frontend..."
cd ../frontend
npm install
GENERATE_SOURCEMAP=false npm run build
if [ $? -ne 0 ]; then
    echo "❌ Failed to build React frontend"
    exit 1
fi

# Go back to server directory
cd ..

echo "🎉 Setup complete! Starting services..."

# Start database API in background with logging
echo "🚀 Starting Database API (Port 3030)..."
cd database
nohup node app.js > ../database.log 2>&1 &
DATABASE_PID=$!
cd ..

# Wait for database API to be ready
wait_for_service 3030 "Database API"
if [ $? -ne 0 ]; then
    echo "❌ Database API failed to start"
    kill $DATABASE_PID 2>/dev/null
    exit 1
fi

# Start Django server with logging
echo "🚀 Starting Django Server (Port 8000)..."
echo "📱 Application will be available at: http://localhost:8000"
echo "📱 In cloud: https://<username>-8000.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai"
echo ""
echo "📋 Service Status:"
echo "   - Database API: http://localhost:3030"
echo "   - Django App: http://localhost:8000"
echo ""
echo "📄 Logs:"
echo "   - Database API: tail -f database.log"
echo "   - Django: output below"
echo ""
echo "🛑 Press Ctrl+C to stop all services"
echo ""

# Trap Ctrl+C to kill background processes
trap 'echo ""; echo "🛑 Stopping services..."; kill $DATABASE_PID 2>/dev/null; echo "✅ All services stopped"; exit' INT

# Start Django with better error handling and keep it in foreground for cloud environments
python3 manage.py runserver 0.0.0.0:8000

# If Django stops unexpectedly, cleanup
kill $DATABASE_PID 2>/dev/null
echo "✅ All services stopped"
