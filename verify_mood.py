import requests

BASE_URL = "http://127.0.0.1:8002"
EMAIL = "testmood_dynamic@example.com"
PWD = "testpassword123"

def verify():
    res = requests.post(f"{BASE_URL}/api/auth/login/", json={"email": EMAIL, "password": PWD})
    token = res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    sum_res = requests.get(f"{BASE_URL}/api/moods/summary/", headers=headers)
    print(f"RAW: {sum_res.text}")
    data = sum_res.json()
    
    print(f"DOMINANT: {data.get('dominant_mood')}")
    print(f"TOTAL: {data.get('total_entries')}")
    print(f"SUMMARY: {data.get('summary')}")
    print(f"SUGGESTIONS: {len(data.get('suggestions', []))} items")

if __name__ == "__main__":
    verify()
