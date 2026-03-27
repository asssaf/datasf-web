module ApiClient exposing (Property, TargetLookupResult, fetchProperties, fetchTargetParcel)

import Http
import Json.Decode as Decode exposing (Decoder, field, list, string, float, maybe, oneOf, succeed)
import Json.Decode.Extra exposing (andMap)
import QueryBuilder exposing (QueryParams, buildFullSoQL)
import Url.Builder

type alias Property =
    { closed_roll_year : Maybe String
    , property_location : Maybe String
    , parcel_number : Maybe String
    , assessor_neighborhood_code : Maybe String
    , property_area : Maybe Float
    , number_of_bedrooms : Maybe Float
    , number_of_bathrooms : Maybe Float
    , current_sales_date : Maybe String
    , property_class_code : Maybe String
    , year_property_built : Maybe Float
    , assessed_improvement_value : Maybe Float
    , assessed_land_value : Maybe Float
    , the_geom : Maybe Geometry
    , number_of_rooms : Maybe Float
    , total_assessed_value : Maybe Float
    , distance_from_target : Maybe Float
    , property_area_ratio : Maybe Float
    , total_assessed_value_ratio : Maybe Float
    , raw_json : Decode.Value
    }

type alias Geometry =
    { coordinates : (Float, Float) }

decodeGeometry : Decoder Geometry
decodeGeometry =
    Decode.map Geometry
        (field "coordinates" (Decode.map2 Tuple.pair (Decode.index 0 float) (Decode.index 1 float)))

decodeProperty : Decoder Property
decodeProperty =
    succeed Property
        |> andMap (maybe (field "closed_roll_year" string))
        |> andMap (maybe (field "property_location" string))
        |> andMap (maybe (field "parcel_number" string))
        |> andMap (maybe (field "assessor_neighborhood_code" string))
        |> andMap (maybe (field "property_area" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "number_of_bedrooms" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "number_of_bathrooms" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "current_sales_date" string))
        |> andMap (maybe (field "property_class_code" string))
        |> andMap (maybe (field "year_property_built" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "assessed_improvement_value" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "assessed_land_value" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "the_geom" decodeGeometry))
        |> andMap (maybe (field "number_of_rooms" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "total_assessed_value" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "distance_from_target" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "property_area_ratio" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap (maybe (field "total_assessed_value_ratio" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        |> andMap Decode.value

fetchProperties : Maybe (Float, Float) -> Maybe Float -> Maybe Float -> List String -> QueryParams -> Int -> Int -> (Result Http.Error (List Property) -> msg) -> Cmd msg
fetchProperties targetPoint targetArea targetTotalValue requestedFields params limit offset toMsg =
    let
        soql = buildFullSoQL targetPoint targetArea targetTotalValue requestedFields params limit offset
        url = Url.Builder.crossOrigin "https://data.sfgov.org" [ "resource", "wv5m-vpq2.json" ] [ Url.Builder.string "$query" soql ]
    in
    Http.get
        { url = url
        , expect = Http.expectJson toMsg (list decodeProperty)
        }

type alias TargetLookupResult =
    { the_geom : Maybe Geometry
    , property_area : Maybe Float
    , assessed_improvement_value : Maybe Float
    , assessed_land_value : Maybe Float
    , assessed_fixtures_value : Maybe Float
    }

decodeTargetLookup : Decoder TargetLookupResult
decodeTargetLookup =
    Decode.map5 TargetLookupResult
        (maybe (field "the_geom" decodeGeometry))
        (maybe (field "property_area" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        (maybe (field "assessed_improvement_value" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        (maybe (field "assessed_land_value" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))
        (maybe (field "assessed_fixtures_value" (oneOf [float, Decode.map (String.toFloat >> Maybe.withDefault 0.0) string])))

fetchTargetParcel : String -> String -> (Result Http.Error (List TargetLookupResult) -> msg) -> Cmd msg
fetchTargetParcel parcelNumber rollYear toMsg =
    let
        where_ = "parcel_number = \"" ++ parcelNumber ++ "\" AND closed_roll_year = \"" ++ rollYear ++ "\""
        select = "the_geom, property_area, assessed_improvement_value, assessed_land_value, assessed_fixtures_value"
        url = Url.Builder.crossOrigin "https://data.sfgov.org" [ "resource", "wv5m-vpq2.json" ] [ Url.Builder.string "$query" ("SELECT " ++ select ++ " WHERE " ++ where_ ++ " LIMIT 1") ]
    in
    Http.get
        { url = url
        , expect = Http.expectJson toMsg (list decodeTargetLookup)
        }
