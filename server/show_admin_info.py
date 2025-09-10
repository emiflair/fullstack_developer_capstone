#!/usr/bin/env python3
"""
Display current admin credentials saved in the database
"""

import os
import sys
import django
from pathlib import Path

# Add the current directory to the Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'djangoproj.settings')
django.setup()

from django.contrib.auth.models import User

def show_admin_info():
    """Show admin user information"""
    print("="*60)
    print("DJANGO ADMIN LOGIN CREDENTIALS")
    print("="*60)
    
    admin_users = User.objects.filter(is_staff=True)
    
    if not admin_users.exists():
        print("❌ No admin users found in database!")
        print("Run: python manage.py createsuperuser")
        return
    
    for user in admin_users:
        print(f"✅ Admin User Found:")
        print(f"   Username: {user.username}")
        print(f"   Email: {user.email}")
        print(f"   Staff Status: {'✅ Yes' if user.is_staff else '❌ No'}")
        print(f"   Superuser: {'✅ Yes' if user.is_superuser else '❌ No'}")
        print(f"   Created: {user.date_joined.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"   Last Login: {user.last_login.strftime('%Y-%m-%d %H:%M:%S') if user.last_login else 'Never'}")
        print("-" * 60)
    
    print("\n🌐 Admin Panel URLs:")
    print("   Local: http://127.0.0.1:8000/admin/")
    print("   Local: http://localhost:8000/admin/")
    
    print("\n📝 Note: Passwords are securely hashed and stored in the database.")
    print("   If you forgot your password, use: python manage_admin_users.py")

if __name__ == "__main__":
    show_admin_info()
