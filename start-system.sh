#!/bin/bash

echo "🚨 EMERGENCY: System-Level Django Installation"
echo "============================================="

# Install Django at system level (bypass virtual environment)
echo "📦 Installing Django system-wide..."
pip3 install --user Django==4.2.24
pip3 install --user djangorestframework==3.14.0
pip3 install --user requests==2.31.0
pip3 install --user Pillow==10.0.0
pip3 install --user python-dotenv==1.0.0

# Test Django
echo "🧪 Testing Django..."
python3 -c "import django; print(f'✅ Django {django.get_version()} working!')"

if [ $? -ne 0 ]; then
    echo "❌ System Django installation failed"
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
echo "�� Starting Database API..."
cd database
node app.js &
DATABASE_PID=$!
cd ..

# Wait for database
sleep 3

# Start Django
echo "🚀 Starting Django Server..."
echo "📱 Application available at:"
echo "   Cloud: https://<username>-8000.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai"
echo ""
echo "🛑 Press Ctrl+C to stop all services"

# Trap for cleanup
trap 'echo ""; echo "🛑 Stopping services..."; kill $DATABASE_PID 2>/dev/null; echo "✅ Stopped"; exit' INT

# Start Django
python3 manage.py runserver 0.0.0.0:8000

# Cleanup
kill $DATABASE_PID 2>/dev/null
echo "✅ All services stopped"
