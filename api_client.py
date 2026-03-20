import requests

class APIClient:
    DEFAULT_BASE_URL = "https://data.sfgov.org"
    DEFAULT_ENDPOINT = "/resource/wv5m-vpq2.json"

    def __init__(self, base_url=None, default_endpoint=None, verify=True):
        self.base_url = (base_url or self.DEFAULT_BASE_URL).rstrip('/')
        self.default_endpoint = default_endpoint or self.DEFAULT_ENDPOINT
        self.verify = verify

    def get(self, endpoint=None, params=None, headers=None):
        target_endpoint = endpoint or self.default_endpoint
        url = f"{self.base_url}/{target_endpoint.lstrip('/')}"
        try:
            response = requests.get(url, params=params, headers=headers, verify=self.verify)
            return response
        except requests.RequestException as e:
            # Handle generic request exceptions
            raise e
