import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1/ml"

def test_anomaly_detection():
    print("Testing Anomaly Detection...")
    url = f"{BASE_URL}/detect-anomalies"
    
    # Test Case 1: Critical Vitals (High BP, Low SpO2)
    data_critical = {
        "vitals": {
            "systolic_bp": 180, # Anomaly (High)
            "spo2": 88,         # Anomaly (Low)
            "heart_rate": 72
        },
        "labs": {
            "creatinine": 1.0
        }
    }
    
    # Test Case 2: Historical Drift (Sudden spike in HR though within range)
    data_drift = {
        "vitals": {
            "heart_rate": 95 # Within range (60-100) BUT high vs history
        },
        "history": [
            {"heart_rate": 60},
            {"heart_rate": 62},
            {"heart_rate": 61}
        ]
    }

    try:
        # Test Critical
        print("\nSending Critical Vitals...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_critical).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            issues = [a['parameter'] for a in result['anomalies']]
            if "systolic_bp" in issues and "spo2" in issues:
                print("[OK] Detected Critical Vitals anomalies")
            else:
                 print(f"[FAIL] Expected anomalies, got {issues}")

        # Test Drift
        print("\nSending Historical Drift Data...")
        req = urllib.request.Request(url, 
            data=json.dumps(data_drift).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            if result['is_anomalous']:
                 print("[OK] Detected Sudden Change anomaly")
            else:
                 print("[FAIL] Failed to detect drift")

    except Exception as e:
        print(f"[ERROR] Request failed: {e}")

if __name__ == "__main__":
    test_anomaly_detection()
