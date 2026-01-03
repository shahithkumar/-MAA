import requests
import json

BASE_URL = "http://127.0.0.1:8002"

def test_stress_buster_ai():
    print("--- Testing Stress Buster AI Analysis ---")
    
    # 1. Login to get token (using a known user or trying a dummy)
    # Note: Replace with actual test credentials if needed
    login_data = {
        "email": "testuser@example.com",
        "password": "Password123!"
    }
    
    print("Logging in...")
    login_response = requests.post(f"{BASE_URL}/api/auth/login/", json=login_data)
    
    if login_response.status_code != 200:
        print("Login failed, attempting to register test user...")
        reg_data = {
            "name": "Test User",
            "age": 25,
            "phone_number": "1234567890",
            "gender": "Other",
            "email": "testuser_unique_123@example.com",
            "password": "Password123!",
            "confirm_password": "Password123!",
            "guardian_name": "Guardian Name",
            "guardian_relationship": "Parent",
            "guardian_phone_number": "0987654321",
            "guardian_email": "guardian@example.com"
        }
        reg_response = requests.post(f"{BASE_URL}/api/auth/register/", json=reg_data)
        if reg_response.status_code == 201:
            print("Registration successful.")
            login_response = requests.post(f"{BASE_URL}/api/auth/login/", json=login_data)
        else:
            print(f"Registration failed: {reg_response.text}")
            return

    token = login_response.json().get("access_token")
    headers = {"Authorization": f"Bearer {token}"}
    
    # 2. Test Stress Buster AI
    venting_text = "I am feeling extremely overwhelmed with my work projects. My boss keeps adding more tasks and I feel like I am going to fail everything. I am losing sleep over this."
    
    print(f"\nVenting text: {venting_text}")
    print("Submitting for analysis...")
    
    payload = {
        "duration": 120,
        "note_text": venting_text
    }
    
    response = requests.post(f"{BASE_URL}/api/sessions/stress-buster/", json=payload, headers=headers)
    
    if response.status_code == 201:
        result = response.json()
        feedback = result.get("feedback", "No feedback received")
        print("\n--- AI FEEDBACK RECEIVED ---")
        print(feedback)
        print("----------------------------")
        
        # Verify if it contains "Analysis" and "Proposed Solution" as requested in our prompt
        if "Analysis" in feedback and "Proposed Solution" in feedback:
            print("\n✅ Success: AI response follows the new structured format.")
        else:
            print("\n⚠️ Warning: AI response might be missing the required sections.")
    else:
        print(f"Failed to get AI feedback: {response.text}")

if __name__ == "__main__":
    test_stress_buster_ai()
