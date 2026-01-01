import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1"

def test_lab_recommendations():
    print("\nTesting Lab Recommendations...")
    url = f"{BASE_URL}/labs/recommend"
    
    test_cases = [
        ("Fever", ["CBC", "Malaria"]),
        ("Hypertension", ["Lipid Profile"]),
        ("Chest Pain", ["ECG"]),
        ("Unknown Disease", [])  # Should return empty
    ]
    
    for diagnosis, expected_keywords in test_cases:
        data = {"diagnosis": diagnosis}
        req = urllib.request.Request(url, 
            data=json.dumps(data).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        
        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
                print(f" Diagnosis: '{diagnosis}' -> Got {len(result)} labs")
                
                # Check if expected keywords are present in any of the returned test names
                found_all = True
                for keyword in expected_keywords:
                    found = any(keyword.lower() in r['test_name'].lower() for r in result)
                    if not found:
                        found_all = False
                        print(f"  [FAIL] Missing expected lab: {keyword}")
                
                if found_all and (len(result) > 0 or len(expected_keywords) == 0):
                    print(f"  [OK] Matches for '{diagnosis}'")
                elif len(expected_keywords) > 0:
                     print(f"  [FAIL] Logic error for '{diagnosis}'")

        except Exception as e:
             print(f" [ERROR] Request failed for '{diagnosis}': {e}")

if __name__ == "__main__":
    test_lab_recommendations()
