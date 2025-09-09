#!/bin/bash

echo "🔍 Testing Django Import in Cloud Environment"
echo "============================================"

# Activate virtual environment
source .venv/bin/activate

echo "📍 Environment Info:"
echo "Python: $(which python3)"
echo "Python version: $(python3 --version)"
echo "Current directory: $(pwd)"

echo ""
echo "🧪 Testing Django Import:"

# Test Django import with detailed error reporting
python3 -c "
try:
    import django
    print(f'✅ Django import successful: {django.get_version()}')
except ImportError as e:
    print(f'❌ Django import failed: {e}')
    import sys
    print(f'Python path: {sys.path}')
except Exception as e:
    print(f'❌ Unexpected error: {e}')
"

echo ""
echo "�� Testing Django REST Framework:"

python3 -c "
try:
    import djangorestframework
    print('✅ Django REST Framework import successful')
except ImportError as e:
    print(f'❌ Django REST Framework import failed: {e}')
except Exception as e:
    print(f'❌ Unexpected error: {e}')
"

echo ""
echo "�� Testing Django Management Commands:"
cd server
python3 -c "
import os
import sys
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'djangoproj.settings')
try:
    django.setup()
    print('✅ Django setup successful')
    from django.core.management import execute_from_command_line
    print('✅ Django management commands available')
except Exception as e:
    print(f'❌ Django setup failed: {e}')
"

echo ""
echo "🎯 Django test complete!"
