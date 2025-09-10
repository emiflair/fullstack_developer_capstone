#!/usr/bin/env python3
"""
Admin User Management Script for Django Project
This script helps you manage admin users for the Django admin panel.
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
from django.core.exceptions import ValidationError


def list_admin_users():
    """List all admin users in the database."""
    print("\n=== Admin Users ===")
    admin_users = User.objects.filter(is_staff=True)
    
    if not admin_users.exists():
        print("No admin users found.")
        return
    
    for user in admin_users:
        print(f"Username: {user.username}")
        print(f"Email: {user.email}")
        print(f"Is Staff: {user.is_staff}")
        print(f"Is Superuser: {user.is_superuser}")
        print(f"Date Joined: {user.date_joined}")
        print(f"Last Login: {user.last_login}")
        print("-" * 40)


def create_admin_user():
    """Create a new admin user."""
    print("\n=== Create New Admin User ===")
    
    username = input("Enter username: ").strip()
    if not username:
        print("Username cannot be empty.")
        return
    
    if User.objects.filter(username=username).exists():
        print(f"User '{username}' already exists.")
        return
    
    email = input("Enter email: ").strip()
    password = input("Enter password: ").strip()
    
    if not password:
        print("Password cannot be empty.")
        return
    
    try:
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password
        )
        user.is_staff = True
        user.is_superuser = True
        user.save()
        
        print(f"Admin user '{username}' created successfully!")
        
    except ValidationError as e:
        print(f"Validation error: {e}")
    except Exception as e:
        print(f"Error creating user: {e}")


def reset_password():
    """Reset password for an existing user."""
    print("\n=== Reset User Password ===")
    
    username = input("Enter username: ").strip()
    if not username:
        print("Username cannot be empty.")
        return
    
    try:
        user = User.objects.get(username=username)
        new_password = input("Enter new password: ").strip()
        
        if not new_password:
            print("Password cannot be empty.")
            return
        
        user.set_password(new_password)
        user.save()
        
        print(f"Password for user '{username}' has been reset successfully!")
        
    except User.DoesNotExist:
        print(f"User '{username}' does not exist.")
    except Exception as e:
        print(f"Error resetting password: {e}")


def main():
    """Main menu for the admin user management script."""
    while True:
        print("\n" + "="*50)
        print("Django Admin User Management")
        print("="*50)
        print("1. List all admin users")
        print("2. Create new admin user")
        print("3. Reset user password")
        print("4. Exit")
        print("-" * 50)
        
        choice = input("Enter your choice (1-4): ").strip()
        
        if choice == '1':
            list_admin_users()
        elif choice == '2':
            create_admin_user()
        elif choice == '3':
            reset_password()
        elif choice == '4':
            print("Goodbye!")
            break
        else:
            print("Invalid choice. Please enter 1, 2, 3, or 4.")


if __name__ == "__main__":
    main()
