import pytest
import sys
import os

# Add the root directory to sys.path to allow importing from the app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from api_client import APIClient

def test_api_client_defaults_to_sf_data_api():
    # This test will fail because APIClient currently requires base_url
    client = APIClient() 
    assert client.base_url == "https://data.sfgov.org"

def test_api_client_default_endpoint():
    client = APIClient()
    # Let's assume we'll store default_endpoint as an attribute
    assert client.default_endpoint == "/resource/wv5m-vpq2.json"
