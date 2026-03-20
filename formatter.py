import json

def format_json(response_text):
    """Attempt to parse and pretty-print JSON response text."""
    try:
        data = json.loads(response_text)
        return json.dumps(data, indent=2)
    except (json.JSONDecodeError, TypeError):
        # If not JSON, return original text
        return response_text
