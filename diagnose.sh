#!/bin/bash

echo "🔍 Car Dealership App Diagnostic Tool"
echo "====================================="

echo "�� Current Directory:"
pwd
echo ""

echo "📂 Project Structure:"
if [ -f "server/manage.py" ]; then
    echo "✅ Django project found"
else
    echo "❌ Django project NOT found"
fi

if [ -f "server/database/app.js" ]; then
    echo "✅ Database API found"
else
    echo "❌ Database API NOT found"
fi

if [ -d "server/frontend" ]; then
    echo "✅ Frontend directory found"
else
    echo "❌ Frontend directory NOT found"
fi
echo ""

echo "🐍 Python Environment:"
echo "System Python: $(which python3)"
echo "System Python Version: $(python3 --version)"

if [ -d ".venv" ]; then
    echo "✅ Virtual environment found at .venv"
    source .venv/bin/activate
    echo "Activated Python: $(which python3)"
    echo "Activated Pip: $(which pip)"
    
    echo ""
    echo "📦 Django Status:"
    python3 -c "import django; print(f'Django version: {django.get_version()}')" 2>/dev/null && echo "✅ Django working" || echo "❌ Django NOT working"
    
elif [ -d "server/.venv" ]; then
    echo "✅ Virtual environment found at server/.venv"
else
    echo "❌ No virtual environment found"
fi
echo ""

echo "📡 Network Tools:"
command -v lsof >/dev/null && echo "✅ lsof available" || echo "❌ lsof NOT available"
command -v netstat >/dev/null && echo "✅ netstat available" || echo "❌ netstat NOT available"
command -v curl >/dev/null && echo "✅ curl available" || echo "❌ curl NOT available"
echo ""

echo "🔌 Port Status:"
if command -v lsof >/dev/null 2>&1; then
    echo "Port 8000: $(lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1 && echo "IN USE" || echo "FREE")"
    echo "Port 3030: $(lsof -Pi :3030 -sTCP:LISTEN -t >/dev/null 2>&1 && echo "IN USE" || echo "FREE")"
else
    echo "Cannot check ports (lsof not available)"
fi
echo ""

echo "💾 Dependencies:"
echo "Node.js: $(command -v node >/dev/null && node --version || echo "NOT FOUND")"
echo "npm: $(command -v npm >/dev/null && npm --version || echo "NOT FOUND")"
echo ""

echo "🌍 Environment Detection:"
if [ -n "$HOSTNAME" ] && [[ "$HOSTNAME" == *"theiadocker"* ]]; then
    echo "🌩️  Running in IBM Skills Network (Theia Docker)"
elif [ -n "$USER" ] && [[ "$USER" == "project" ]]; then
    echo "🌩️  Running in IBM Cloud Environment"
elif [ "$(uname)" == "Darwin" ]; then
    echo "🖥️  Running on macOS (Local)"
elif [ "$(uname)" == "Linux" ]; then
    echo "🐧 Running on Linux"
else
    echo "❓ Unknown environment"
fi
echo ""

echo "Diagnostic complete! 🎯"
