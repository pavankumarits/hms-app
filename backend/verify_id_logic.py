
import requests
import json
import datetime
import sys

BASE_URL = "http://localhost:8005/api/v1"
LOGIN_URL = f"{BASE_URL}/login/access-token"
PATIENTS_URL = f"{BASE_URL}/patients/"

# 1. Login to get token
def login(username, password):
    response = requests.post(LOGIN_URL, data={"username": username, "password": password})
    if response.status_code != 200:
        print(f"Login failed: {response.text}")
        sys.exit(1)
    return response.json()["access_token"]

# 2. Create Patient
def create_patient(token, uiid, name):
    headers = {"Authorization": f"Bearer {token}"}
    data = {
        "name": name,
        "gender": "Male",
        "dob": "1990-01-01",
        "patient_uiid": uiid, # Explicitly requesting this ID
        "phone": "1234567890",
        "address": "Test Address"
    }
    response = requests.post(PATIENTS_URL, json=data, headers=headers)
    return response

def test_logic():
    print("--- Verifying Sequential ID Conflict Resolution ---")
    
    # We need a valid user. Assuming 'admin' / 'admin' or similar exists from previous setup.
    # If not, we might fail. Let's try standard credentials or checking check_users.py
    try:
        token = login("admin", "pass111")
        print("Login Successful.")
    except SystemExit:
         print("Could not login with admin/admin. Checking DB directly might be needed or user info.")
         return

    # Generate a test ID for today
    today_str = datetime.datetime.now().strftime("%Y%m%d")
    test_seq_id = f"P{today_str}-9001" # Use high number to avoid clash with real data
    
    # Attempt 1: Create Patient A with ID 9001
    print(f"\nAttempt 1: Creating Patient A with ID {test_seq_id}...")
    res1 = create_patient(token, test_seq_id, "Test Patient A")
    if res1.status_code == 200:
        data1 = res1.json()
        print(f"Success! Assigned ID: {data1.get('patient_uiid')}")
    else:
        print(f"Failed: {res1.text}")
        
    # Attempt 2: Create Patient B with SAME ID 9001
    print(f"\nAttempt 2: Creating Patient B with SAME ID {test_seq_id} (Should Auto-Correct)...")
    res2 = create_patient(token, test_seq_id, "Test Patient B")
    if res2.status_code == 200:
        data2 = res2.json()
        assigned_id = data2.get('patient_uiid')
        print(f"Success! Assigned ID: {assigned_id}")
        
        # Verify it Auto-Corrected
        if assigned_id != test_seq_id and assigned_id.endswith("9002"): 
             print("VERIFICATION PASSED: ID was auto-incremented to ...9002")
        else:
             print(f"VERIFICATION WARNING: ID was {assigned_id}, expected ...9002")
             
    else:
        print(f"Failed: {res2.text}")
        print("VERIFICATION FAILED: Backend did not handle conflict.")

if __name__ == "__main__":
    test_logic()
