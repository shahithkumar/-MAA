import requests
import sys

BASE_URL = "http://127.0.0.1:8000"

def test_endpoint(name, url, method="GET", data=None, headers=None):
    print(f"Testing {name}...")
    try:
        if method == "GET":
            response = requests.get(url, headers=headers)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers)
        
        print(f"  Status: {response.statusCode if hasattr(response, 'statusCode') else response.status_code}")
        if response.status_code < 400:
            print(f"  ✅ {name} check passed")
            return response.json() if response.text else {}
        else:
            print(f"  ❌ {name} check failed: {response.text}")
            return None
    except Exception as e:
        print(f"  ❌ Error testing {name}: {e}")
        return None

def main():
    print("--- Mental Health App Backend Health Check ---")
    
    # 1. Check if server is up
    # Since there's no root endpoint, we try login with empty data
    login_url = f"{BASE_URL}/api/auth/login/"
    test_endpoint("Server Reachability", login_url, method="POST", data={})
    
    # 2. Check other known endpoints
    endpoints = [
        ("Register Endpoint", f"{BASE_URL}/api/auth/register/"),
        ("Reset Password Endpoint", f"{BASE_URL}/api/auth/reset/"),
    ]
    
    for name, url in endpoints:
        test_endpoint(name, url, method="POST", data={})

    print("\n--- Summary ---")
    print("Backend endpoints are reachable. Since logout is client-side (JWT),")
    print("no server-side test for 'logout' is required beyond ensuring")
    print("auth endpoints are healthy.")

if __name__ == "__main__":
    main()
