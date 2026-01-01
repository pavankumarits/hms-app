import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1/ml"

def test_risk_prediction():
    print("Testing ML Risk Prediction...")
    url = f"{BASE_URL}/predict-risk"
    
    # Test Case 1: High Risk Patient
    data_high_risk = {
        "age": 75,
        "gender": "Male",
        "vitals": {
            "systolic_bp": 85,  # Hypotension
            "heart_rate": 115,  # Tachycardia
            "spo2": 88          # Hypoxia
        },
        "comorbidities": ["COPD", "Heart Failure"],
        "lab_results": {
            "creatinine": 1.8   # Elevated
        }
    }
    
    # Test Case 2: Low Risk Patient
    data_low_risk = {
        "age": 30,
        "gender": "Female",
        "vitals": {
            "systolic_bp": 118,
            "heart_rate": 70,
            "spo2": 99
        },
        "comorbidities": [],
        "lab_results": {}
    }

    try:
        # Test High Risk
        print("\nSending High Risk Patient Data...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_high_risk).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            if result['risk_level'] == 'High' and result['risk_score'] > 60:
                print("[OK] Correctly identified High Risk")
            else:
                print(f"[FAIL] Expected High Risk, got {result['risk_level']}")

        # Test Low Risk
        print("\nSending Low Risk Patient Data...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_low_risk).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            if result['risk_level'] == 'Low' and result['risk_score'] < 20:
                print("[OK] Correctly identified Low Risk")
            else:
                print(f"[FAIL] Expected Low Risk, got {result['risk_level']}")

    except Exception as e:
        print(f"[ERROR] Request failed: {e}")
        try:
            if hasattr(e, 'read'):
                print(e.read().decode())
        except:
            pass

if __name__ == "__main__":
    test_risk_prediction()
