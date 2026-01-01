import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1/ml"

def test_nlp_diagnosis():
    print("Testing NLP Diagnosis...")
    url = f"{BASE_URL}/predict-diagnosis-nlp"
    
    # Test Case 1: Viral Infection
    data_viral = {
        "symptoms": "I have a high fever, cough, and runny nose with sneezing"
    }
    
    # Test Case 2: Cardiac
    data_cardiac = {
        "symptoms": "Severe chest pain radiating to my left arm and sweating"
    }

    try:
        # Test Viral
        print("\nSending Viral Symptoms...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_viral).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            # Check for matches
            names = [r['name'] for r in result]
            if "Viral Upper Respiratory Infection" in names or "Viral Fever" in names:
                print("[OK] Correctly identified Viral Infection")
            else:
                print(f"[FAIL] Expected Viral, got {names}")

        # Test Cardiac
        print("\nSending Cardiac Symptoms...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_cardiac).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            names = [r['name'] for r in result]
            if "Myocardial Infarction (Heart Attack)" in names or "Angina Pectoris" in names or "Angina" in names:
                print("[OK] Correctly identified Cardiac Issue")
            else:
                 print(f"[FAIL] Expected Cardiac, got {names}")

    except Exception as e:
        print(f"[ERROR] Request failed: {e}")

if __name__ == "__main__":
    test_nlp_diagnosis()
