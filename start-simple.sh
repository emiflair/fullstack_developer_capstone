#!/bin/bash

echo "🚀 Simple Car Dealership Startup (Skip Verification)"
echo "=================================================="

# Check directory
if [ ! -f "server/manage.py" ]; then
    echo "❌ Error: Run from project root directory"
    exit 1
fi

# Activate existing virtual environment
echo "🐍 Activating Python environment..."
source .venv/bin/activate

echo "📍 Environment:"
echo "Python: $(which python3)"
echo "Python version: $(python3 --version)"

# Go to server directory
cd server

echo "��️  Running Django migrations..."
python3 manage.py migrate

echo "📦 Installing Node.js dependencies..."
cd database
npm install

echo "⚛️  Building React frontend..."
cd ../frontend
npm install
GENERATE_SOURCEMAP=false npm run build

# Start services
cd ..
echo "🎉 Starting services..."

# Start database API
echo "🚀 Starting Database API..."
cd database
node app.js &
DATABASE_PID=$!
cd ..

# Wait for database
sleep 3

# Start Django
echo "🚀 Starting Django Server..."
echo "📱 Application will be available at:"
echo "   Local: http://localhost:8000"
echo "   Cloud: https://<username>-8000.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai"
echo ""
echo "🛑 Press Ctrl+C to stop all services"

# Trap for cleanup
trap 'echo ""; echo "🛑 Stopping services..."; kill $DATABASE_PID 2>/dev/null; echo "✅ Stopped"; exit' INT

# Start Django server (no verification, just start)
python3 manage.py runserver 0.0.0.0:8000

# Cleanup
kill $DATABASE_PID 2>/dev/null
echo "✅ All services stopped"
