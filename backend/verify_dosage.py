import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1"

def test_dosage_calculator():
    print("\nTesting Dosage Calculator...")
    url = f"{BASE_URL}/dosage/calculate"
    
    test_cases = [
        # 1. Child Paracetamol (10kg, 2yo) -> 15mg/kg -> 150mg
        {
            "drug_name": "Paracetamol",
            "weight_kg": 10.0,
            "age_years": 2.0,
            "form": "Syrup"
        },
        # 2. Child Ibuprofen (15kg, 4yo) -> 10mg/kg -> 150mg
        {
            "drug_name": "Ibuprofen",
            "weight_kg": 15.0,
            "age_years": 4.0,
            "form": "Syrup"
        },
        # 3. Adult Paracetamol (60kg) -> Fixed (40kg+) -> usually max cap check
        {
            "drug_name": "Paracetamol",
            "weight_kg": 70.0,
            "age_years": 30.0,
            "form": "Tablet"
        }
    ]
    
    for case in test_cases:
        req = urllib.request.Request(url, 
            data=json.dumps(case).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        
        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
                drug = case['drug_name']
                weight = case['weight_kg']
                print(f" Request: {drug} for {weight}kg")
                print(f"  -> Dose: {result['calculated_dose_mg']}mg")
                if result.get('calculated_dose_ml'):
                    print(f"  -> Volume: {result['calculated_dose_ml']}ml")
                print(f"  -> Freq: {result['frequency']}")
                if result.get('warning'):
                    print(f"  -> Warning: {result['warning']}")
                print("  [OK]")

        except Exception as e:
             print(f" [ERROR] Request failed for {case['drug_name']}: {e}")

if __name__ == "__main__":
    test_dosage_calculator()
