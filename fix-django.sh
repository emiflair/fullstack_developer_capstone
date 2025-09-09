#!/bin/bash

echo "🔧 Django Fix Script for Cloud Environments"
echo "=========================================="

# Activate virtual environment
if [ -d ".venv" ]; then
    echo "🐍 Activating virtual environment..."
    source .venv/bin/activate
else
    echo "❌ Virtual environment not found"
    exit 1
fi

echo "📍 Current Python environment:"
echo "Python: $(which python3)"
echo "Pip: $(which pip)"
echo "Python version: $(python3 --version)"

echo ""
echo "🗑️  Cleaning Django installation..."
pip uninstall -y Django djangorestframework

echo ""
echo "🧹 Clearing pip cache..."
pip cache purge

echo ""
echo "📦 Reinstalling Django with specific versions..."
pip install --no-cache-dir Django==4.2.24
pip install --no-cache-dir djangorestframework

echo ""
echo "🔍 Verifying Django installation..."
python3 -c "import django; print(f'✅ Django {django.get_version()} installed successfully')"

echo ""
echo "📋 Checking Django admin command..."
cd server
python3 manage.py check --deploy

echo ""
echo "🎯 Django fix complete!"
