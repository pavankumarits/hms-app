import urllib.request
import json
import time

url = 'http://127.0.0.1:8000/api/v1/setup'
payload = {
    'hospital_name': 'TimeoutTest',
    'admin_username': 'timeout_user',
    'admin_password': 'password123',
    'admin_pin': '1234'
}

print(f"Sending request to {url}...")
start_time = time.time()

try:
    req = urllib.request.Request(
        url, 
        data=json.dumps(payload).encode('utf-8'), 
        headers={'Content-Type': 'application/json'}
    )
    response = urllib.request.urlopen(req, timeout=10) # 10s timeout
    print(f"Response: {response.read().decode('utf-8')}")
    print(f"Time taken: {time.time() - start_time:.2f}s")
except Exception as e:
    print(f"ERROR: {e}")
    print(f"Time taken before error: {time.time() - start_time:.2f}s")
