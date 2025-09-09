#!/bin/bash

echo "🌩️  Car Dealership App - Cloud Fix & Start"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "server/manage.py" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Create fresh virtual environment in cloud
echo "🐍 Setting up fresh Python environment..."
rm -rf .venv
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

echo "📍 Python environment details:"
echo "Python: $(which python3)"
echo "Pip: $(which pip)"  
echo "Python version: $(python3 --version)"

# Upgrade pip first
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Use cloud-optimized requirements if available, fallback to regular
if [ -f "server/requirements-cloud.txt" ]; then
    REQUIREMENTS_FILE="server/requirements-cloud.txt"
    echo "📦 Using cloud-optimized requirements..."
else
    REQUIREMENTS_FILE="server/requirements.txt"
    echo "📦 Using standard requirements..."
fi

# Install dependencies with verbose output for debugging
echo "📦 Installing Python dependencies..."
pip install --no-cache-dir -r $REQUIREMENTS_FILE

# Verify Django installation
echo "🔍 Verifying Django installation..."
python3 -c "
import django
print(f'✅ Django {django.get_version()} installed successfully')
import djangorestframework
print(f'✅ Django REST Framework installed')
"

if [ $? -ne 0 ]; then
    echo "❌ Django verification failed"
    exit 1
fi

# Run Django setup
echo "🗃️  Setting up Django..."
cd server
python3 manage.py check
python3 manage.py migrate

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
cd database
npm install

# Build React frontend
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

# Start Django server
python3 manage.py runserver 0.0.0.0:8000

# Cleanup if Django stops
kill $DATABASE_PID 2>/dev/null
echo "✅ All services stopped"
