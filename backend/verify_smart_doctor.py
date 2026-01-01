import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1/smart-doctor"

def test_predict():
    print("Testing Prediction...")
    url = f"{BASE_URL}/predict-drugs"
    data = {
        "diagnosis": "Hypertension",
        "age": 45,
        "gender": "Male"
    }
    req = urllib.request.Request(url, 
        data=json.dumps(data).encode('utf-8'), 
        headers={'Content-Type': 'application/json'}
    )
    
    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            if result and result[0]['drug_name'] == 'Amlodipine 5mg':
                print("[OK] Prediction Test Passed!")
            else:
                print("[FAIL] Prediction Result Mismatch")
    except Exception as e:
        print(f"[FAIL] Prediction Failed: {e}")

def test_safety():
    print("\nTesting Safety Check...")
    url = f"{BASE_URL}/check-safety"
    data = {
        "proposed_drug": "Amlodipine",
        "current_meds": ["Simvastatin"]
    }
    req = urllib.request.Request(url, 
        data=json.dumps(data).encode('utf-8'), 
        headers={'Content-Type': 'application/json'}
    )
    
    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            if not result['is_safe'] and "Simvastatin" in result['warnings'][0]:
                print("[OK] Safety Check Passed! (Warning Detected)")
            else:
                print("[FAIL] Safety Check Failed (No warning?)")
    except Exception as e:
        print(f"[FAIL] Safety Check Failed: {e}")

if __name__ == "__main__":
    test_predict()
    test_safety()
