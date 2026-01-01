import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1"

def test_prescription_audit():
    print("\nTesting Prescription Audit (Drug Interactions)...")
    url = f"{BASE_URL}/prescription/audit"
    
    test_cases = [
        # 1. Major Interaction: Simvastatin + Erythromycin
        {
            "new_drug": "Erythromycin 250mg",
            "current_meds": ["Simvastatin 20mg"],
            "expected_interaction": True,
            "match_drug": "Simvastatin"
        },
        # 2. Major Interaction: Warfarin + Aspirin
        {
            "new_drug": "Aspirin 81mg",
            "current_meds": ["Warfarin 5mg"],
            "expected_interaction": True,
            "match_drug": "Warfarin"
        },
        # 3. Safe Combination: Paracetamol + Amoxicillin
        {
            "new_drug": "Paracetamol 500mg",
            "current_meds": ["Amoxicillin 500mg"],
            "expected_interaction": False,
            "match_drug": None
        },
        # 4. Bidirectional Check: Warfarin (New) + Aspirin (Current)
        {
            "new_drug": "Warfarin 2mg",
            "current_meds": ["Aspirin 81mg"],
            "expected_interaction": True,
            "match_drug": "Aspirin"
        }
    ]
    
    for case in test_cases:
        # Prepare input payload
        payload = {
            "new_drug": case["new_drug"],
            "current_meds": case["current_meds"]
        }
        
        req = urllib.request.Request(url, 
            data=json.dumps(payload).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        
        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
                print(f" Request: Combine {case['new_drug']} with {case['current_meds']}")
                
                interactions = result['interactions']
                if interactions:
                    print(f"  -> Found {len(interactions)} interactions")
                    for i in interactions:
                        print(f"    - ⚠️ {i['severity']}: {i['interacting_drug']} + New Drug ({i['description']})")
                else:
                    print("  -> Safe to prescribe (No interactions found)")
                
                # Check expectation
                if case['expected_interaction']:
                     if interactions:
                         print("  [OK] Interaction Correctly Identified")
                     else:
                         print("  [FAIL] Expected interaction but got none")
                else:
                     if not interactions:
                         print("  [OK] Correctly identified as safe")
                     else:
                         print("  [FAIL] Expected safe but got interaction")

        except Exception as e:
             print(f" [ERROR] Request failed: {e}")

if __name__ == "__main__":
    test_prescription_audit()
