#!/usr/bin/env python3
"""
Simple admin login test for the Docker container
"""

import requests
import re

def test_admin_login():
    base_url = "http://localhost:8000"
    
    # Create a session to maintain cookies
    session = requests.Session()
    
    print("🔍 Testing Django Admin Login in Container")
    print("=" * 50)
    
    # Step 1: Get the login page
    print("1. Getting login page...")
    login_url = f"{base_url}/admin/login/"
    response = session.get(login_url)
    
    if response.status_code != 200:
        print(f"❌ Failed to get login page: {response.status_code}")
        return False
    
    print(f"✅ Login page loaded (status: {response.status_code})")
    
    # Step 2: Extract CSRF token
    csrf_match = re.search(r'name="csrfmiddlewaretoken" value="([^"]*)"', response.text)
    if not csrf_match:
        print("❌ CSRF token not found in login page")
        return False
    
    csrf_token = csrf_match.group(1)
    print(f"✅ CSRF token extracted: {csrf_token[:20]}...")
    
    # Step 3: Attempt login
    print("2. Attempting login...")
    login_data = {
        'username': 'emifeaustin',
        'password': 'dealership123',
        'csrfmiddlewaretoken': csrf_token,
        'next': '/admin/'
    }
    
    response = session.post(login_url, data=login_data, allow_redirects=False)
    
    print(f"Login response status: {response.status_code}")
    
    if response.status_code == 302:
        redirect_location = response.headers.get('Location', '')
        print(f"✅ Login successful! Redirected to: {redirect_location}")
        
        # Step 4: Follow redirect to admin dashboard
        if redirect_location:
            print("3. Accessing admin dashboard...")
            admin_response = session.get(f"{base_url}{redirect_location}")
            if admin_response.status_code == 200 and "Django administration" in admin_response.text:
                print("✅ Admin dashboard accessible!")
                return True
            else:
                print("❌ Admin dashboard not accessible")
        return True
    
    elif response.status_code == 200:
        if "Please enter the correct username and password" in response.text:
            print("❌ Login failed: Invalid credentials")
        elif "CSRF verification failed" in response.text:
            print("❌ Login failed: CSRF verification failed")
        else:
            print("❌ Login failed: Unknown reason")
        print("Response content (first 500 chars):")
        print(response.text[:500])
        return False
    
    else:
        print(f"❌ Unexpected response status: {response.status_code}")
        return False

if __name__ == "__main__":
    success = test_admin_login()
    if success:
        print("\n🎉 Container admin login working correctly!")
    else:
        print("\n💥 Container admin login has issues.")
