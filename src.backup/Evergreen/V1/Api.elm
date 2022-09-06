module Evergreen.V1.Api exposing (..)

import Evergreen.V1.QueryBuilder
import ISO8601


type Val
    = Varchar_ String
    | Time_ ISO8601.Time
    | Bool_ Bool
    | Float_ Float
    | Int_ Int
    | Unknown


type alias Column =
    { ref : Evergreen.V1.QueryBuilder.ColumnRef
    , type_ : String
    , vals : List (Maybe Val)
    }


type alias DuckDbQueryResponse =
    { columns : List Column
    }


type alias TableRef =
    String


type alias DuckDbTableRefsResponse =
    { refs : List TableRef
    }


type alias ColumnDescription =
    { ref : Evergreen.V1.QueryBuilder.ColumnRef
    , type_ : String
    }


type alias DuckDbMetaResponse =
    { colDescs : List ColumnDescription
    }
