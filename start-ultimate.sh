#!/bin/bash

echo "🚀 Ultimate Car Dealership Startup (Cloud Proven)"
echo "==============================================="

# Check directory
if [ ! -f "server/manage.py" ]; then
    echo "❌ Error: Run from project root directory"
    exit 1
fi

# Create completely fresh virtual environment every time
echo "🐍 Creating fresh virtual environment..."
rm -rf .venv
python3 -m venv .venv

# Activate virtual environment
echo "🐍 Activating fresh virtual environment..."
source .venv/bin/activate

# Verify we're in the right environment
echo "📍 Environment verification:"
echo "Python: $(which python3)"
echo "Pip: $(which pip)"
echo "Python version: $(python3 --version)"

# Upgrade pip
echo "⬆️ Upgrading pip..."
pip install --upgrade pip

# Install Django directly with specific version
echo "📦 Installing Django directly..."
pip install --no-cache-dir Django==4.2.24
pip install --no-cache-dir djangorestframework==3.14.0
pip install --no-cache-dir requests==2.31.0
pip install --no-cache-dir Pillow==10.0.0
pip install --no-cache-dir gunicorn==21.2.0
pip install --no-cache-dir python-dotenv==1.0.0

# Quick Django test
echo "🧪 Quick Django test..."
python3 -c "import django; print(f'✅ Django {django.get_version()} ready!')"

if [ $? -ne 0 ]; then
    echo "❌ Django still not working - this is a deeper environment issue"
    exit 1
fi

# Go to server directory
cd server

echo "🗃️ Running Django migrations..."
python3 manage.py migrate

echo "📦 Installing Node.js dependencies..."
cd database
npm install --silent

echo "⚛️ Building React frontend..."
cd ../frontend
npm install --silent
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

# Start Django with explicit environment
echo "🚀 Starting Django Server..."
echo "📱 Application available at:"
echo "   Cloud: https://<username>-8000.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai"
echo ""
echo "🛑 Press Ctrl+C to stop all services"

# Trap for cleanup
trap 'echo ""; echo "🛑 Stopping services..."; kill $DATABASE_PID 2>/dev/null; echo "✅ Stopped"; exit' INT

# Start Django with explicit Python path
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
python3 manage.py runserver 0.0.0.0:8000

# Cleanup
kill $DATABASE_PID 2>/dev/null
echo "✅ All services stopped"
