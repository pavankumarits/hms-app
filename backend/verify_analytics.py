import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000/api/v1/ml"

def test_analytics():
    print("Testing ML Analytics Dashboard...")
    url = f"{BASE_URL}/dashboard-insights"
    
    try:
        req = urllib.request.Request(url, method='GET')
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print("Response:", json.dumps(result, indent=2))
            
            if "outbreak_prediction" in result and "resource_forecast" in result:
                print("[OK] Successfully retrieved aggregated ML insights")
            else:
                 print("[FAIL] Missing key insight fields")

    except Exception as e:
        print(f"[ERROR] Request failed: {e}")

if __name__ == "__main__":
    test_analytics()
