
import urllib.request
import urllib.parse
import json

def get_token():
    url = "http://localhost:8000/api/v1/login/access-token"
    # Default admin credentials
    data = urllib.parse.urlencode({'username': 'admin@example.com', 'password': 'password'}).encode()
    req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode())['access_token']

try:
    token = get_token()
    print(f"Got Token: {token[:10]}...")
    
    req = urllib.request.Request("http://localhost:8000/api/v1/patients/")
    req.add_header('Authorization', f'Bearer {token}')
    
    with urllib.request.urlopen(req) as url:
        data = json.loads(url.read().decode())
        print("API Response Success:")
        print(json.dumps(data, indent=2))
except Exception as e:
    print(f"Error: {e}")
