module Tests exposing (..)

import Expect
import Test exposing (..)
import QueryBuilder exposing (..)

suite : Test
suite =
    describe "QueryBuilder"
        [ describe "buildWhereClause"
            [ test "handles basic filters" <|
                \_ ->
                    let
                        params = { defaultQueryParams | bedrooms = Just "2", roll_year = Just "2021" }
                        result = buildWhereClause params
                    in
                    -- In Elm's String.fromFloat 2.0 is "2"
                    if (String.contains "number_of_bedrooms IN (\"2\")" result || String.contains "number_of_bedrooms IN (\"2.0\")" result)
                       && String.contains "closed_roll_year = \"2021\"" result then
                        Expect.pass
                    else
                        Expect.fail ("Incorrect SoQL: " ++ result)
            , test "handles multi filters" <|
                \_ ->
                    let
                        params = { defaultQueryParams | districts = ["9", "10"] }
                        result = buildWhereClause params
                    in
                    Expect.equal "caseless_one_of(assessor_neighborhood_district, \"9\", \"10\")" result
            ]
        , describe "getSelectedFields"
            [ test "includes default fields when no target" <|
                \_ ->
                    let
                        fields = getSelectedFields Nothing Nothing Nothing []
                    in
                    if List.member "parcel_number" fields && List.member "total_assessed_value" fields && not (List.member "distance_from_target" fields) then
                        Expect.pass
                    else
                        Expect.fail ("Incorrect fields: " ++ String.join ", " fields)
            , test "includes calculated fields when target provided" <|
                \_ ->
                    let
                        fields = getSelectedFields (Just (0, 0)) (Just 1000) (Just 500000) []
                    in
                    if List.member "distance_from_target" fields && List.member "property_area_ratio" fields && List.member "total_assessed_value_ratio" fields then
                        Expect.pass
                    else
                        Expect.fail ("Incorrect fields: " ++ String.join ", " fields)
            ]
        ]
