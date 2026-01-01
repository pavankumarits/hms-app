import urllib.request
import json
import time
import statistics

BASE_URL = "http://localhost:8000/api/v1/ml"

ENDPOINTS = [
    ("Risk", "predict-risk", {
        "age": 75, "gender": "Male", "vitals": {"systolic_bp": 85, "heart_rate": 115}, "comorbidities": ["COPD"]
    }),
    ("Readmission", "predict-readmission", {
        "length_of_stay_days": 10, "is_acute_admission": True, "comorbidities": ["Start Failure"], "ed_visits_last_6m": 2
    }),
    ("NLP", "predict-diagnosis-nlp", {
        "symptoms": "chest pain and sweating"
    }),
    ("Treatment", "predict-treatment", {
        "diagnosis": "Hypertension", "age": 70, "gender": "Male", "comorbidities": ["Kidney Disease"]
    }),
    ("Anomaly", "detect-anomalies", {
        "vitals": {"systolic_bp": 180, "spo2": 88}, "labs": {}
    }),
    ("Triage", "predict-triage", {
        "symptoms": "crushing chest pain", "vitals": {"heart_rate": 110}, "pain_score": 9, "consciousness": "Alert"
    }),
    ("Analytics", "dashboard-insights", None)
]

def benchmark():
    print("========================================")
    print("      ML PERFORMANCE BENCHMARK          ")
    print("========================================")
    
    results = {}

    for name, endpoint, data in ENDPOINTS:
        latencies = []
        url = f"{BASE_URL}/{endpoint}"
        
        print(f"Benchmarking {name}...", end="", flush=True)
        
        for _ in range(5): # 5 iterations
            try:
                start = time.perf_counter()
                if data is None:
                    req = urllib.request.Request(url, method='GET')
                else:
                    req = urllib.request.Request(url, 
                        data=json.dumps(data).encode('utf-8'), 
                        headers={'Content-Type': 'application/json'}
                    )
                with urllib.request.urlopen(req) as response:
                    response.read()
                end = time.perf_counter()
                latencies.append((end - start) * 1000) # ms
            except Exception as e:
                print(f" Error: {e}")
                break
        
        if latencies:
            avg_lat = statistics.mean(latencies)
            max_lat = max(latencies)
            print(f" Avg: {avg_lat:.2f}ms | Max: {max_lat:.2f}ms")
            results[name] = avg_lat
        else:
            print(" Failed")

    print("\n========================================")
    print("CONCLUSION:")
    if all(l < 200 for l in results.values()):
        print("✅ All systems go! (Latency < 200ms)")
    else:
        print("⚠️ Some endpoints are slow (> 200ms). Optimization recommended.")
    print("========================================")

if __name__ == "__main__":
    benchmark()
