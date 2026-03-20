import sys
import os
import json

# Add the root directory to sys.path to allow importing from the app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from formatter import format_json, format_table

def test_format_valid_json():
    input_text = '{"key": "value", "list": [1, 2, 3]}'
    expected_output = json.dumps({"key": "value", "list": [1, 2, 3]}, indent=2)
    assert format_json(input_text) == expected_output

def test_format_invalid_json():
    input_text = 'Invalid JSON text'
    assert format_json(input_text) == input_text

def test_format_empty_input():
    assert format_json('') == ''

def test_format_none_input():
    assert format_json(None) == None

def test_format_table_valid():
    data = [
        {"id": "1", "name": "Alice"},
        {"id": "2", "name": "Bob"}
    ]
    input_text = json.dumps(data)
    # 2 chars for 'id', 5 for 'name'
    # Row: '1  | Alice'
    #      '2  | Bob  '
    output = format_table(input_text)
    assert "id | name" in output
    assert "1  | Alice" in output
    assert "2  | Bob  " in output

def test_format_table_not_list():
    input_text = '{"key": "value"}'
    assert format_table(input_text) == "No data found or invalid format for table."

def test_format_table_invalid_json():
    input_text = "Invalid JSON"
    assert format_table(input_text) == input_text
