def build_select_clause():
    fields = [
        "closed_roll_year",
        "property_location",
        "parcel_number",
        "assessor_neighborhood_district",
        "property_area",
        "number_of_bedrooms",
        "number_of_bathrooms",
        "current_sales_date"
    ]
    return ", ".join(fields)

def build_where_clause(params):
    filters = []
    
    if 'bedrooms' in params:
        val = float(params['bedrooms'])
        filters.append(f'number_of_bedrooms IN ("{val}")')
    
    if 'bathrooms' in params:
        val = float(params['bathrooms'])
        filters.append(f'number_of_bathrooms IN ("{val}")')
        
    return " AND ".join(filters)
