module VegaUtilsTest exposing (..)

import DuckDb exposing (DuckDbColumn(..), DuckDbRef_(..), Val(..))
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import VegaUtils exposing (ColumnParamed, mapColToFloatCol, mapColToIntegerCol, mapColToStringCol)


suite : Test
suite =
    describe "VegaUtils module"
        [ describe "mapping types"
            [ test "string"
                (\_ ->
                    mapColToStringCol stringColumn
                        |> Expect.equal colParamedString
                )
            , test "int"
                (\_ ->
                    mapColToIntegerCol integerColumn
                        |> Expect.equal colParamedInt
                )
            , test "FLOAT"
                (\_ ->
                    mapColToFloatCol floatColumn
                        |> Expect.equal colParamedFloat
                )
            ]
        ]


stringColumn : DuckDbColumn
stringColumn =
    Persisted
        { name = "a string column"
        , parentRef = defaultParentRef
        , dataType = "VARCHAR"
        , vals =
            [ Just (Varchar_ "one")
            , Just (Varchar_ "two")
            , Just (Varchar_ "three")
            ]
        }


colParamedString : ColumnParamed String
colParamedString =
    { ref = "a string column"
    , vals = [ "one", "two", "three" ]
    }


integerColumn : DuckDbColumn
integerColumn =
    Persisted
        { name = "an int column"
        , parentRef = defaultParentRef
        , dataType = "INTEGER"
        , vals =
            [ Just (Int_ 1)
            , Just (Int_ 2)
            , Just (Int_ 3)
            ]
        }


colParamedInt : ColumnParamed Int
colParamedInt =
    { ref = "an int column"
    , vals = [ 1, 2, 3 ]
    }


floatColumn : DuckDbColumn
floatColumn =
    Persisted
        { name = "a float column"
        , parentRef = defaultParentRef
        , dataType = "DOUBLE"
        , vals =
            [ Just (Float_ 3.1)
            , Just (Float_ 3.14)
            , Just (Float_ 3.2)
            ]
        }


colParamedFloat : ColumnParamed Float
colParamedFloat =
    { ref = "a float column"
    , vals = [ 3.1, 3.14, 3.2 ]
    }


defaultParentRef : DuckDbRef_
defaultParentRef =
    DuckDbTable { schemaName = "elm_test", tableName = "a_test" }
