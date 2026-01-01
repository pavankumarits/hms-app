import urllib.request
import json
import sys
import time

BASE_URL = "http://localhost:8000/api/v1/ml"

def run_test(name, endpoint, data, description=""):
    print(f"\n--- Testing {name} ---")
    if description: print(f"Scenario: {description}")
    url = f"{BASE_URL}/{endpoint}"
    
    try:
        if endpoint == "dashboard-insights":
             req = urllib.request.Request(url, method='GET')
        else:
            req = urllib.request.Request(url, 
                data=json.dumps(data).encode('utf-8'), 
                headers={'Content-Type': 'application/json'}
            )
            
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            # print("Result:", json.dumps(result, indent=2))
            print(f"[OK] {name} Endpoint Responsive")
            return True, result
    except Exception as e:
        print(f"[FAIL] {name} Failed: {e}")
        return False, None

def test_all_ml_features():
    print("========================================")
    print("      HMS AI/ML PHASE 2 VERIFICATION    ")
    print("========================================")
    
    passed = 0
    total = 7
    
    # 1. Risk Prediction
    success, _ = run_test("Patient Risk", "predict-risk", {
        "age": 75, "gender": "Male", "vitals": {"systolic_bp": 85, "heart_rate": 115}, "comorbidities": ["COPD"]
    }, "High Risk Patient")
    if success: passed += 1

    # 2. Readmission Prediction
    success, _ = run_test("Readmission", "predict-readmission", {
        "length_of_stay_days": 10, "is_acute_admission": True, "comorbidities": ["Start Failure"], "ed_visits_last_6m": 2
    }, "High Probability")
    if success: passed += 1

    # 3. NLP Diagnosis
    success, res = run_test("NLP Diagnosis", "predict-diagnosis-nlp", {
        "symptoms": "chest pain and sweating"
    }, "Cardiac Symptoms")
    if success and res:
         print(f"   -> Top Diagnosis: {res[0]['name']} ({res[0]['confidence']}%)")
         passed += 1

    # 4. Treatment Prediction
    success, res = run_test("Treatment Outcome", "predict-treatment", {
        "diagnosis": "Hypertension", "age": 70, "gender": "Male", "comorbidities": ["Kidney Disease"]
    }, "Elderly Hypertension")
    if success and res:
         print(f"   -> Recommended: {res[0]['drug_name']}")
         passed += 1

    # 5. Anomaly Detection
    success, res = run_test("Anomaly Detection", "detect-anomalies", {
        "vitals": {"systolic_bp": 180, "spo2": 88}, "labs": {}
    }, "Critical Vitals")
    if success and res:
         print(f"   -> Detected {res['anomaly_count']} anomalies")
         passed += 1

    # 6. Smart Triage
    success, res = run_test("Smart Triage", "predict-triage", {
        "symptoms": "crushing chest pain", "vitals": {"heart_rate": 110}, "pain_score": 9, "consciousness": "Alert"
    }, "Emergency Case")
    if success and res:
         print(f"   -> Level: {res['triage_level']} ({res['category']})")
         passed += 1
         
    # 7. Analytics Dashboard
    success, res = run_test("Analytics Dashboard", "dashboard-insights", {}, "Population Insights")
    if success and res:
         print(f"   -> Outbreak Alert: {res['outbreak_prediction']['alert']}")
         passed += 1

    print("\n========================================")
    print(f"SUMMARY: {passed}/{total} Modules Operational")
    print("========================================")

if __name__ == "__main__":
    # Wait a bit for server to fully reload if just started
    time.sleep(2) 
    test_all_ml_features()
