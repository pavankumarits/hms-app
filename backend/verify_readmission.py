import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1/ml"

def test_readmission_prediction():
    print("Testing Readmission Prediction...")
    url = f"{BASE_URL}/predict-readmission"
    
    # Test Case 1: High Risk (Long stay, acute, comorbidities, recent ED visits)
    data_high_risk = {
        "length_of_stay_days": 10,  # +5 pts
        "is_acute_admission": True, # +3 pts
        "comorbidities": ["Diabetes", "Heart Failure", "COPD"], # +3 pts
        "ed_visits_last_6m": 2      # +2 pts = Total > 10
    }
    
    # Test Case 2: Low Risk
    data_low_risk = {
        "length_of_stay_days": 2,
        "is_acute_admission": False,
        "comorbidities": [],
        "ed_visits_last_6m": 0
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
            
            if result['risk_level'] == 'High':
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
            
            if result['risk_level'] == 'Low':
                print("[OK] Correctly identified Low Risk")
            else:
                print(f"[FAIL] Expected Low Risk, got {result['risk_level']}")

    except Exception as e:
        print(f"[ERROR] Request failed: {e}")

if __name__ == "__main__":
    test_readmission_prediction()
