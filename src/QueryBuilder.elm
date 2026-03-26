module QueryBuilder exposing (..)

import Url.Builder exposing (QueryParameter, string)

type alias QueryParams =
    { roll_year : Maybe String
    , bedrooms : Maybe String
    , bathrooms : Maybe String
    , parcel_number : Maybe String
    , area_min : Maybe String
    , area_max : Maybe String
    , date_start : Maybe String
    , date_end : Maybe String
    , districts : List String
    , neighborhood_codes : List String
    , property_class_codes : List String
    }

defaultQueryParams : QueryParams
defaultQueryParams =
    { roll_year = Nothing
    , bedrooms = Nothing
    , bathrooms = Nothing
    , parcel_number = Nothing
    , area_min = Nothing
    , area_max = Nothing
    , date_start = Nothing
    , date_end = Nothing
    , districts = []
    , neighborhood_codes = []
    , property_class_codes = []
    }

getSelectedFields : Maybe (Float, Float) -> Maybe Float -> Maybe Float -> List String -> List String
getSelectedFields targetPoint targetArea targetTotalValue requestedFields =
    let
        defaultFields =
            [ "closed_roll_year"
            , "property_location"
            , "parcel_number"
            , "assessor_neighborhood_code"
            , "property_area"
            , "number_of_bedrooms"
            , "number_of_bathrooms"
            , "current_sales_date"
            , "property_class_code"
            , "year_property_built"
            , "assessed_improvement_value"
            , "assessed_land_value"
            , "the_geom"
            , "number_of_rooms"
            , "total_assessed_value"
            ]

        fieldsToUse =
            if List.isEmpty requestedFields then
                let
                    base = defaultFields
                    withDist =
                        case targetPoint of
                            Just _ -> "distance_from_target" :: base
                            Nothing -> base
                    withArea =
                        case targetArea of
                            Just _ -> "property_area_ratio" :: withDist
                            Nothing -> withDist
                    withTotal =
                        case targetTotalValue of
                            Just _ -> "total_assessed_value_ratio" :: withArea
                            Nothing -> withArea
                in
                List.sort withTotal
            else
                List.filter (\f ->
                    case f of
                        "distance_from_target" -> targetPoint /= Nothing
                        "property_area_ratio" -> targetArea /= Nothing
                        "total_assessed_value_ratio" -> targetTotalValue /= Nothing
                        _ -> True
                ) requestedFields
    in
    fieldsToUse

buildSelectClause : Maybe (Float, Float) -> Maybe Float -> Maybe Float -> List String -> String
buildSelectClause targetPoint targetArea targetTotalValue requestedFields =
    let
        fields = getSelectedFields targetPoint targetArea targetTotalValue requestedFields

        mapField field =
            case field of
                "distance_from_target" ->
                    case targetPoint of
                        Just (lon, lat) ->
                            "distance_in_meters(`the_geom`, 'POINT (" ++ String.fromFloat lon ++ " " ++ String.fromFloat lat ++ ")') AS distance_from_target"
                        Nothing -> ""
                "property_area_ratio" ->
                    case targetArea of
                        Just area -> "property_area / " ++ String.fromFloat area ++ " AS property_area_ratio"
                        Nothing -> ""
                "total_assessed_value_ratio" ->
                    case targetTotalValue of
                        Just total ->
                            let
                                totalExpr = "(coalesce(assessed_improvement_value, 0) + coalesce(assessed_land_value, 0) + coalesce(assessed_fixtures_value, 0))"
                            in
                            totalExpr ++ " / " ++ String.fromFloat total ++ " AS total_assessed_value_ratio"
                        Nothing -> ""
                "total_assessed_value" ->
                    "coalesce(assessed_improvement_value, 0) + coalesce(assessed_land_value, 0) + coalesce(assessed_fixtures_value, 0) AS total_assessed_value"
                _ -> field
    in
    fields
        |> List.map mapField
        |> List.filter (not << String.isEmpty)
        |> String.join ", "

buildWhereClause : QueryParams -> String
buildWhereClause params =
    let
        filters = []
            |> addFilter (params.bedrooms |> Maybe.andThen String.toFloat |> Maybe.map (\v -> "number_of_bedrooms IN (\"" ++ String.fromFloat v ++ "\")"))
            |> addFilter (params.bathrooms |> Maybe.andThen String.toFloat |> Maybe.map (\v -> "number_of_bathrooms IN (\"" ++ String.fromFloat v ++ "\")"))
            |> addFilter (params.parcel_number |> Maybe.map (\v -> "parcel_number = \"" ++ v ++ "\""))
            |> addAreaFilter params.area_min params.area_max
            |> addDateFilter params.date_start params.date_end
            |> addMultiFilter "assessor_neighborhood_district" params.districts
            |> addMultiFilter "property_class_code" params.property_class_codes
            |> addMultiFilter "assessor_neighborhood_code" params.neighborhood_codes
            |> addFilter (params.roll_year |> Maybe.map (\v -> "closed_roll_year = \"" ++ v ++ "\""))
    in
    String.join " AND " filters

addFilter : Maybe String -> List String -> List String
addFilter maybeFilter filters =
    case maybeFilter of
        Just filter -> filter :: filters
        Nothing -> filters

addAreaFilter : Maybe String -> Maybe String -> List String -> List String
addAreaFilter min max filters =
    case (min, max) of
        (Just mn, Just mx) -> ("property_area BETWEEN " ++ mn ++ " AND " ++ mx) :: filters
        (Just mn, Nothing) -> ("property_area >= " ++ mn) :: filters
        (Nothing, Just mx) -> ("property_area <= " ++ mx) :: filters
        (Nothing, Nothing) -> filters

addDateFilter : Maybe String -> Maybe String -> List String -> List String
addDateFilter start end filters =
    case (start, end) of
        (Just s, Just e) -> ("current_sales_date BETWEEN '" ++ s ++ "'::floating_timestamp AND '" ++ e ++ "'::floating_timestamp") :: filters
        (Just s, Nothing) -> ("current_sales_date >= '" ++ s ++ "'::floating_timestamp") :: filters
        (Nothing, Just e) -> ("current_sales_date <= '" ++ e ++ "'::floating_timestamp") :: filters
        (Nothing, Nothing) -> filters

addMultiFilter : String -> List String -> List String -> List String
addMultiFilter field values filters =
    if List.isEmpty values then
        filters
    else
        let
            quotedValues = values |> List.map (\v -> "\"" ++ v ++ "\"") |> String.join ", "
        in
        ("caseless_one_of(" ++ field ++ ", " ++ quotedValues ++ ")") :: filters

buildOrderByClause : Maybe (Float, Float) -> Maybe Float -> String
buildOrderByClause targetPoint targetArea =
    let
        parts = []
            |> addPart (targetPoint |> Maybe.map (\(lon, lat) -> "distance_in_meters(`the_geom`, 'POINT (" ++ String.fromFloat lon ++ " " ++ String.fromFloat lat ++ ")')"))
            |> addPart (targetArea |> Maybe.map (\area -> "property_area / " ++ String.fromFloat area))

        addPart maybePart acc =
            case maybePart of
                Just part -> part :: acc
                Nothing -> acc
    in
    String.join ", " (List.reverse parts)

buildFullSoQL : Maybe (Float, Float) -> Maybe Float -> Maybe Float -> List String -> QueryParams -> Int -> Int -> String
buildFullSoQL targetPoint targetArea targetTotalValue requestedFields params limit offset =
    let
        select = buildSelectClause targetPoint targetArea targetTotalValue requestedFields
        where_ = buildWhereClause params
        order = buildOrderByClause targetPoint targetArea

        base = "SELECT " ++ select
        withWhere = if String.isEmpty where_ then base else base ++ " WHERE " ++ where_
        withOrder = if String.isEmpty order then withWhere else withWhere ++ " ORDER BY " ++ order
    in
    withOrder ++ " LIMIT " ++ String.fromInt limit ++ " OFFSET " ++ String.fromInt offset
