import urllib.request
import urllib.parse
import json
import ssl

# URL for the local backend
url = "http://127.0.0.1:8000/api/v1/login/access-token"

# Credentials to test
data = {
    "username": "admin",
    "password": "pass111"
}

# Encode data for POST
encoded_data = urllib.parse.urlencode(data).encode('utf-8')

print(f"Testing Login API: {url}")
print(f"Credentials: {data['username']} / *****")

try:
    # Create request
    req = urllib.request.Request(url, data=encoded_data, method='POST')
    # Add headers if needed (e.g. Content-Type for form data is automatic with urlencode)
    
    # Perform request
    with urllib.request.urlopen(req) as response:
        status_code = response.getcode()
        print(f"Status Code: {status_code}")
        
        response_body = response.read().decode('utf-8')
        
        if status_code == 200:
            data = json.loads(response_body)
            token = data.get("access_token")
            if token:
                print("SUCCESS: Login successful!")
                print(f"Received Token: {token[:20]}...")
                
                # Now test GET /users/me
                me_url = "http://127.0.0.1:8000/api/v1/users/me"
                print(f"Testing Protected API: {me_url}")
                
                req_me = urllib.request.Request(me_url, method='GET')
                req_me.add_header("Authorization", f"Bearer {token}")
                
                try:
                    with urllib.request.urlopen(req_me) as response_me:
                        print(f"User API Status Code: {response_me.getcode()}")
                        print(f"User Data: {response_me.read().decode('utf-8')}")
                except urllib.error.HTTPError as e_me:
                    print(f"FAILURE: User API Failed {e_me.code}")
                    print(e_me.read().decode('utf-8'))

            else:
                print("FAILURE: No token in response.")
                print(response_body)
        else:
            print("FAILURE: Login failed.")
            print(f"Response: {response_body}")

except urllib.error.HTTPError as e:
    print(f"FAILURE: HTTP Error {e.code}")
    print(e.read().decode('utf-8'))
except Exception as e:
    print(f"ERROR: Could not connect to server. Is it running? {e}")
