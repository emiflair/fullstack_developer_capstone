#!/bin/bash

echo "🔍 Environment Debugging Tool"
echo "============================"

echo "📍 Current working directory:"
pwd

echo ""
echo "🐍 System Python info:"
echo "System Python: $(which python3)"
echo "System Python version: $(python3 --version)"
echo "System pip: $(which pip)"

echo ""
echo "📂 Virtual environment status:"
if [ -d ".venv" ]; then
    echo "✅ .venv directory exists"
    echo "Size: $(du -sh .venv | cut -f1)"
    echo "Contents: $(ls -la .venv/)"
    
    echo ""
    echo "🔧 Attempting to activate .venv..."
    source .venv/bin/activate
    
    echo "After activation:"
    echo "Python: $(which python3)"
    echo "Pip: $(which pip)"
    echo "Python version: $(python3 --version)"
    
    echo ""
    echo "📦 Installed packages:"
    pip list | grep -E "(Django|django)"
    
    echo ""
    echo "🧪 Django import test:"
    python3 -c "
import sys
print('Python path:')
for p in sys.path:
    print(f'  {p}')
print()
try:
    import django
    print(f'✅ Django import successful: {django.get_version()}')
    print(f'Django location: {django.__file__}')
except Exception as e:
    print(f'❌ Django import failed: {e}')
"
else
    echo "❌ .venv directory does not exist"
fi

echo ""
echo "🌍 Environment variables:"
echo "PYTHONPATH: ${PYTHONPATH:-'Not set'}"
echo "VIRTUAL_ENV: ${VIRTUAL_ENV:-'Not set'}"
echo "PATH: $PATH"

echo ""
echo "🎯 Debug complete!"
