#!/bin/bash

echo "🎯 DIRECT Django Installation (No Virtual Environment)"
echo "====================================================="

# Set Python path to include local installations
export PYTHONPATH="/home/theia/.local/lib/python3.10/site-packages:$PYTHONPATH"

# Install packages directly to user directory  
echo "📦 Installing Django directly to user space..."
python3 -m pip install --user --force-reinstall Django==4.2.24
python3 -m pip install --user --force-reinstall djangorestframework==3.14.0
python3 -m pip install --user --force-reinstall requests==2.31.0
python3 -m pip install --user --force-reinstall Pillow==10.0.0
python3 -m pip install --user --force-reinstall python-dotenv==1.0.0

# Show where packages are installed
echo "📍 Package installation location:"
python3 -m site --user-site

# Test Django import
echo "🧪 Testing Django import..."
python3 -c "
import sys
print('Python version:', sys.version)
print('Python path:')
for p in sys.path:
    if 'site-packages' in p:
        print(f'  📦 {p}')

try:
    import django
    print(f'✅ SUCCESS: Django {django.get_version()} imported!')
    print(f'Django location: {django.__file__}')
except Exception as e:
    print(f'❌ FAILED: {e}')
    sys.exit(1)
"

if [ $? -ne 0 ]; then
    echo "❌ Django test failed"
    exit 1
fi

echo "✅ Django is working! Starting application..."

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

# Start Django
echo "🚀 Starting Django Server..."
echo "📱 Application available at:"
echo "   Cloud: https://<username>-8000.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai"
echo ""
echo "🛑 Press Ctrl+C to stop all services"

# Trap for cleanup
trap 'echo ""; echo "🛑 Stopping services..."; kill $DATABASE_PID 2>/dev/null; echo "✅ Stopped"; exit' INT

# Start Django with explicit Python path
PYTHONPATH="/home/theia/.local/lib/python3.10/site-packages:$PYTHONPATH" python3 manage.py runserver 0.0.0.0:8000

# Cleanup
kill $DATABASE_PID 2>/dev/null
echo "✅ All services stopped"
