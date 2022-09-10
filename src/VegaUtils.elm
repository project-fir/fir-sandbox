module VegaUtils exposing (..)

import DuckDb exposing (DuckDbColumn(..), Val(..))
import Utils exposing (removeNothingsFromList)


type alias ColumnParamed val =
    { ref : String
    , vals : List val
    }


mapColToStringCol : DuckDbColumn -> ColumnParamed String
mapColToStringCol col =
    let
        mapToStringList : List String -> List Val -> List String
        mapToStringList accum vals__ =
            case vals__ of
                [ Varchar_ i ] ->
                    accum ++ [ i ]

                (Varchar_ i) :: is ->
                    [ i ] ++ mapToStringList accum is

                _ ->
                    []
    in
    case col of
        Persisted col_ ->
            case col_.dataType of
                "VARCHAR" ->
                    { ref = col_.name
                    , vals = mapToStringList [] (removeNothingsFromList col_.vals)
                    }

                _ ->
                    { ref = "ERROR - INT MAP"
                    , vals = []
                    }

        Computed col_ ->
            case col_.dataType of
                "DOUBLE" ->
                    { ref = col_.name
                    , vals = mapToStringList [] (removeNothingsFromList col_.vals)
                    }

                _ ->
                    { ref = "ERROR - INT MAP"
                    , vals = []
                    }


mapColToFloatCol : DuckDbColumn -> ColumnParamed Float
mapColToFloatCol col =
    let
        mapToFloatList : List Float -> List Val -> List Float
        mapToFloatList accum vals__ =
            case vals__ of
                [ Float_ i ] ->
                    accum ++ [ i ]

                (Float_ i) :: is ->
                    [ i ] ++ mapToFloatList accum is

                _ ->
                    []
    in
    case col of
        Persisted col_ ->
            case col_.dataType of
                "DOUBLE" ->
                    { ref = col_.name
                    , vals = mapToFloatList [] (removeNothingsFromList col_.vals)
                    }

                _ ->
                    { ref = "ERROR - INT MAP"
                    , vals = []
                    }

        Computed col_ ->
            case col_.dataType of
                "DOUBLE" ->
                    { ref = col_.name
                    , vals = mapToFloatList [] (removeNothingsFromList col_.vals)
                    }

                _ ->
                    { ref = "ERROR - INT MAP"
                    , vals = []
                    }


mapColToIntegerCol : DuckDbColumn -> ColumnParamed Int
mapColToIntegerCol col =
    let
        mapToIntList : List Int -> List Val -> List Int
        mapToIntList accum vals__ =
            case vals__ of
                [ Int_ i ] ->
                    accum ++ [ i ]

                (Int_ i) :: is ->
                    [ i ] ++ mapToIntList accum is

                _ ->
                    []
    in
    case col of
        Persisted col_ ->
            case col_.dataType of
                "INTEGER" ->
                    { ref = col_.name
                    , vals = mapToIntList [] (removeNothingsFromList col_.vals)
                    }

                _ ->
                    { ref = "ERROR - INT MAP"
                    , vals = []
                    }

        Computed col_ ->
            case col_.dataType of
                "INTEGER" ->
                    { ref = col_.name
                    , vals = mapToIntList [] (removeNothingsFromList col_.vals)
                    }

                _ ->
                    { ref = "ERROR - INT MAP"
                    , vals = []
                    }
