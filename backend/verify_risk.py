import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1"

def test_risk_scoring():
    print("\nTesting Patient Risk Scoring...")
    url = f"{BASE_URL}/risk/assess"
    
    test_cases = [
        # 1. Low Risk: Young, Healthy
        {
            "name": "Jane (25, Healthy)",
            "age": 25,
            "gender": "Female",
            "systolic_bp": 110,
            "diastolic_bp": 70,
            "conditions": [],
            "lifestyle_factors": []
        },
        # 2. Medium Risk: Middle Aged, Smoker
        {
            "name": "Bob (55, Smoker)",
            "age": 55, # +10
            "gender": "Male",
            "systolic_bp": 135, # +5
            "diastolic_bp": 85,
            "conditions": [],
            "lifestyle_factors": ["Smoker"] # +15
            # Total ~30 -> Medium
        },
        # 3. High Risk: Senior, Diabetic, HTN
        {
            "name": "John (70, Chronic)",
            "age": 70, # +15
            "gender": "Male",
            "systolic_bp": 150, # +15
            "diastolic_bp": 95,
            "conditions": ["Diabetes", "Hypertension"], # +10 +10
            "lifestyle_factors": ["Obesity"] # +10
            # Total ~60 -> High
        }
    ]
    
    for case in test_cases:
        # Prepare input payload (remove name)
        payload = {k:v for k,v in case.items() if k != "name"}
        
        req = urllib.request.Request(url, 
            data=json.dumps(payload).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        
        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
                print(f" Request: {case['name']}")
                print(f"  -> Score: {result['total_score']}")
                print(f"  -> Level: {result['risk_level']}")
                contributors = [c['factor'] for c in result['contributors']]
                print(f"  -> Factors: {', '.join(contributors)}")
                print("  [OK]")

        except Exception as e:
             print(f" [ERROR] Request failed for {case['name']}: {e}")

if __name__ == "__main__":
    test_risk_scoring()
