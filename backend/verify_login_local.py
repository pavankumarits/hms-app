import urllib.request
import urllib.parse
import json

URL = "http://127.0.0.1:8000/api/v1/login/access-token"
DATA = {
    "username": "admin",
    "password": "pass111",
    "grant_type": "password" # OAuth2PasswordRequestForm expects this often, though FastAPI handles it flexible sometimes.
}

try:
    data = urllib.parse.urlencode(DATA).encode()
    req = urllib.request.Request(URL, data=data, method="POST")
    # Headers? OAuth2PasswordRequestForm is form-data usually.
    # default content-type for urlencode is application/x-www-form-urlencoded, which is correct.
    
    print(f"Attempting login to {URL} with {DATA}...")
    with urllib.request.urlopen(req) as response:
        print(f"Status Code: {response.status}")
        print(f"Response: {response.read().decode()}")

except urllib.error.HTTPError as e:
    print(f"HTTP Error: {e.code}")
    print(f"Response: {e.read().decode()}")
except Exception as e:
    print(f"Error: {e}")
