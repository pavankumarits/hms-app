import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1/ml"

def test_triage():
    print("Testing Smart Triage System...")
    url = f"{BASE_URL}/predict-triage"
    
    # Test Case 1: Emergency (Chest Pain, high pain)
    data_emergency = {
        "symptoms": "Severe crushing chest pain and sweating",
        "vitals": {
            "heart_rate": 110,
            "systolic_bp": 150
        },
        "pain_score": 9,
        "consciousness": "Alert"
    }
    
    # Test Case 2: Routine (Sore throat)
    data_routine = {
        "symptoms": "Sore throat and mild cough",
        "vitals": {
            "heart_rate": 72,
            "systolic_bp": 118
        },
        "pain_score": 2,
        "consciousness": "Alert"
    }

    try:
        # Test Emergency
        print("\nSending Emergency Case...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_emergency).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            if result['triage_level'] <= 2:
                print("[OK] Correctly classified as Emergency/Emergent")
            else:
                 print(f"[FAIL] Expected Emergency level <= 2, got {result['triage_level']}")

        # Test Routine
        print("\nSending Routine Case...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_routine).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            if result['triage_level'] >= 4:
                 print("[OK] Correctly classified as Less Urgent/Non-Urgent")
            else:
                 print(f"[FAIL] Expected Routine level >= 4, got {result['triage_level']}")

    except Exception as e:
        print(f"[ERROR] Request failed: {e}")

if __name__ == "__main__":
    test_triage()
