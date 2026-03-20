import pytest
import sys
import os

# Add the root directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from query_builder import build_select_clause, build_where_clause

def test_build_select_clause():
    expected_fields = [
        "closed_roll_year",
        "property_location",
        "parcel_number",
        "assessor_neighborhood_district",
        "property_area",
        "number_of_bedrooms",
        "number_of_bathrooms",
        "current_sales_date"
    ]
    select_clause = build_select_clause()
    # SoQL SELECT is a comma separated string
    fields = [f.strip() for f in select_clause.split(',')]
    assert set(fields) == set(expected_fields)

def test_build_where_clause_bedrooms():
    # According to spec, bedrooms 0 should generate 'number_of_bedrooms IN ("0.0")'
    params = {'bedrooms': '2'}
    where = build_where_clause(params)
    assert 'number_of_bedrooms IN ("2.0")' in where

def test_build_where_clause_bathrooms():
    params = {'bathrooms': '1.5'}
    where = build_where_clause(params)
    assert 'number_of_bathrooms IN ("1.5")' in where

def test_build_where_clause_both_numeric():
    params = {'bedrooms': '3', 'bathrooms': '2'}
    where = build_where_clause(params)
    assert 'number_of_bedrooms IN ("3.0")' in where
    assert 'number_of_bathrooms IN ("2.0")' in where
    assert ' AND ' in where
