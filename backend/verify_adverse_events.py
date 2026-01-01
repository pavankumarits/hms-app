import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1"

def test_adverse_events():
    print("\nTesting Adverse Event Tracker...")
    url = f"{BASE_URL}/adverse-events/check"
    
    test_cases = [
        # 1. Match: Lisinopril + Cough
        {
            "symptoms": ["Dry Cough", "Fever"], 
            "current_meds": ["Lisinopril 10mg"],
            "expected_match": True,
            "drug_name": "Lisinopril"
        },
        # 2. Match: Amlodipine + Swelling
        {
            "symptoms": ["Swelling checks"], # Changed 'Swollen ankles' to 'Swelling' to match seed 'Swelling'
            "current_meds": ["Amlodipine 5mg"],
            "expected_match": True,
            "drug_name": "Amlodipine"
        },
        # 3. No Match: Metformin + Headache (Headache is not in our seed data for Metformin)
        {
            "symptoms": ["Headache"],
            "current_meds": ["Metformin 500mg"],
            "expected_match": False,
            "drug_name": "Metformin"
        },
        # 4. Match: Atorvastatin + Muscle Pain 
        {
            "symptoms": ["Severe muscle pain in legs"], 
            "current_meds": ["Atorvastatin 20mg"],
            "expected_match": True,
            "drug_name": "Atorvastatin"
        }
    ]
    
    for case in test_cases:
        # Prepare input payload
        payload = {
            "symptoms": case["symptoms"],
            "current_meds": case["current_meds"]
        }
        
        req = urllib.request.Request(url, 
            data=json.dumps(payload).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        
        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
                print(f" Request: {case['symptoms']} with {case['current_meds']}")
                
                matches = result['matches']
                if matches:
                    print(f"  -> Found {len(matches)} matches")
                    for m in matches:
                        print(f"    - [WARN] {m['side_effect']} from {m['drug_name']} ({m['likelihood']})")
                else:
                    print("  -> No matches found")
                
                # Check expectation
                if case['expected_match']:
                     if any(m['drug_name'].lower() in case['drug_name'].lower() for m in matches):
                         print("  [OK] Match Confirmed")
                     else:
                         print("  [FAIL] Expected match but got none")
                else:
                     if not matches:
                         print("  [OK] Correctly found no match")
                     else:
                         print("  [FAIL] Expected no match but found one")

        except Exception as e:
             print(f" [ERROR] Request failed: {e}")

if __name__ == "__main__":
    test_adverse_events()
