import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1"

def test_clinical_alerts():
    print("\nTesting Clinical Alerts...")
    url = f"{BASE_URL}/alerts/check"
    
    test_cases = [
        # 1. Healthy Young Male -> Check for Hypertension Screen (>18)
        {
            "name": "Mike (25, Healthy)",
            "age": 25,
            "gender": "Male",
            "conditions": []
        },
        # 2. Female, 50 -> Check for Mammogram (>45)
        {
            "name": "Sarah (50, Healthy)",
            "age": 50,
            "gender": "Female",
            "conditions": []
        },
        # 3. Diabetic Patient -> Check for HbA1c, Eye Exam
        {
            "name": "Tom (55, Diabetes)",
            "age": 55,
            "gender": "Male",
            "conditions": ["Diabetes Type 2"]
        },
        # 4. Colonoscopy check (>45)
        {
             "name": "Gary (50, Male)",
             "age": 50,
             "gender": "Male",
             "conditions": []
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
                print(f"  -> Found {result['total_alerts']} alerts")
                for alert in result['alerts']:
                    print(f"    - [{alert['priority']}] {alert['alert_name']}: {alert['message']}")
                print("  [OK]")

        except Exception as e:
             print(f" [ERROR] Request failed for {case['name']}: {e}")

if __name__ == "__main__":
    test_clinical_alerts()
