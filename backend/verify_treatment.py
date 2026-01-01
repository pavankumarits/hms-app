import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1/ml"

def test_treatment_prediction():
    print("Testing Treatment Prediction...")
    url = f"{BASE_URL}/predict-treatment"
    
    # Test Case 1: Elderly Patient with Hypertension
    data_elderly = {
        "diagnosis": "Hypertension",
        "age": 70,
        "gender": "Male",
        "comorbidities": ["Kidney Disease"]
    }
    
    # Test Case 2: Young Female with Migraine
    data_young = {
        "diagnosis": "Migraine",
        "age": 25,
        "gender": "Female",
        "comorbidities": []
    }

    try:
        # Test Elderly
        print("\nSending Elderly Patient Data (Hypertension)...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_elderly).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            # Check if Amlodipine is top recommended (kidney safe)
            if result and result[0]['drug_name'] == "Amlodipine":
                print("[OK] Correctly prioritized Amlodipine for elderly/kidney patient")
            elif result:
                print(f"[WARN] Top drug was {result[0]['drug_name']}")

        # Test Young Female
        print("\nSending Young Female Data (Migraine)...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_young).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            if result:
                 print("[OK] Successfully returned treatment rankings")

    except Exception as e:
        print(f"[ERROR] Request failed: {e}")

if __name__ == "__main__":
    test_treatment_prediction()
