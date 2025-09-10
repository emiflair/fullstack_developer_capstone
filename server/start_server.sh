#!/bin/bash

# Django Server Startup Script

cd "$(dirname "$0")"

echo "🚀 Starting Django Development Server"
echo "======================================"

# Check if virtual environment exists
if [ ! -d "../.venv" ]; then
    echo "❌ Virtual environment not found!"
    echo "Please run: python3 -m venv ../.venv"
    exit 1
fi

# Activate virtual environment and start server
echo "📦 Activating virtual environment..."
source ../.venv/bin/activate

echo "🔍 Checking Django installation..."
python -c "import django; print(f'Django version: {django.get_version()}')"

echo "🗄️  Applying migrations..."
python manage.py migrate --noinput

echo "👤 Testing admin user..."
python test_admin_login.py

echo ""
echo "🌐 Starting server at http://127.0.0.1:8000/"
echo "🔐 Admin panel: http://127.0.0.1:8000/admin/"
echo "👤 Username: emifeaustin"
echo "🔑 Password: admin123"
echo ""
echo "Press Ctrl+C to stop the server"
echo "======================================"

python manage.py runserver
