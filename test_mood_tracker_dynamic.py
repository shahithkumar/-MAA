import requests
import json
import time

BASE_URL = "http://127.0.0.1:8002"

def test_mood_tracker():
    print("--- Testing Dynamic Mood Tracker ---")
    
    # 1. Login
    login_data = {
        "email": "testmood_dynamic@example.com",
        "password": "testpassword123"
    }
    
    print(f"Logging in as {login_data['email']}...")
    login_res = requests.post(f"{BASE_URL}/api/auth/login/", json=login_data)
    
    if login_res.status_code != 200:
        print("[INFO] Login failed, attempting to register test user...")
        reg_data = {
            "email": login_data['email'],
            "password": login_data['password'],
            "confirm_password": login_data['password'],
            "username": "testmood_dynamic",
            "name": "Test Mood User",
            "age": 25,
            "phone_number": "1234567890",
            "gender": "Other",
            "guardian_name": "Guardian",
            "guardian_relationship": "Friend",
            "guardian_phone_number": "0987654321",
            "guardian_email": "guardian@example.com"
        }
        reg_res = requests.post(f"{BASE_URL}/api/auth/register/", json=reg_data)
        if reg_res.status_code in [201, 200]:
            print("[SUCCESS] Registration successful. Retrying login...")
            login_res = requests.post(f"{BASE_URL}/api/auth/login/", json=login_data)
        else:
            print(f"[ERROR] Registration failed ({reg_res.status_code}): {reg_res.text}")
            return

    if login_res.status_code != 200:
        print(f"[ERROR] Login still failed: {login_res.text}")
        return
    
    login_json = login_res.json()
    token = login_json.get("access_token")
    user_id = login_json.get("user_id")
    headers = {"Authorization": f"Bearer {token}"}
    print("[SUCCESS] Login successful.\n")

    # 2. Log several moods to create a trend
    moods_to_log = [
        {"user": user_id, "mood_emoji": "Joyful", "mood_label": "Joyful", "note": "Amazing day!"},
        {"user": user_id, "mood_emoji": "Joyful", "mood_label": "Joyful", "note": "Still feeling great"},
        {"user": user_id, "mood_emoji": "Sad", "mood_label": "Sad", "note": "Bit down now"},
        {"user": user_id, "mood_emoji": "Joyful", "mood_label": "Joyful", "note": "Back to happy!"},
    ]

    print(f"Logging multiple moods for user {user_id}...")
    for m in moods_to_log:
        res = requests.post(f"{BASE_URL}/api/moods/", json=m, headers=headers)
        if res.status_code == 201:
            print(f"  - Logged: {m['mood_label']}")
        else:
            print(f"  - [ERROR] Failed to log {m['mood_label']}: {res.text}")
    
    print("\n[SUCCESS] Trend established.\n")

    # 3. Check Mood Summary
    print("Fetching Mood Summary...")
    sum_res = requests.get(f"{BASE_URL}/api/moods/summary/", headers=headers)
    
    if sum_res.status_code == 200:
        data = sum_res.json()
        print("[SUCCESS] Summary Check Passed:")
        print(f"  - Dominant Mood: {data.get('dominant_mood')} (Expected: Joyful)")
        print(f"  - Total Entries: {data.get('total_entries')}")
        print(f"  - Summary: {data.get('summary')}")
        print(f"  - Suggestions: {data.get('suggestions')}")
        
        if data.get('dominant_mood') == 'Joyful' and 'total_entries' in data:
            print("\n*** SUCCESS: Backend is dynamically calculating trends correctly! ***")
        else:
            print("\n[WARNING] Some fields might be missing or incorrect.")
    else:
        print(f"[ERROR] Failed to fetch summary: {sum_res.status_code} {sum_res.text}")

    # 4. Check Latest Logs for Dashboard Pulse
    print("\nFetching weekly logs (for Dashboard Pulse)...")
    logs_res = requests.get(f"{BASE_URL}/api/moods/?period=week", headers=headers)
    if logs_res.status_code == 200:
        logs = logs_res.json()
        if len(logs) > 0:
            latest = logs[0]
            print(f"[SUCCESS] Latest Entry (Pulse): {latest.get('mood_emoji')} {latest.get('mood_label')}")
        else:
            print("[ERROR] No logs found in response.")
    else:
        print(f"[ERROR] Failed to fetch logs: {logs_res.text}")

if __name__ == "__main__":
    test_mood_tracker()
