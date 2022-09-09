module Evergreen.V6.DuckDb exposing (..)

import ISO8601


type alias ColumnName =
    String


type alias SchemaName =
    String


type alias TableName =
    String


type alias OwningRef =
    { schemaName : SchemaName
    , tableName : TableName
    }


type DuckDbRef
    = View OwningRef
    | Table OwningRef


type Val
    = Varchar_ String
    | Time_ ISO8601.Time
    | Bool_ Bool
    | Float_ Float
    | Int_ Int
    | Unknown


type alias DuckDbColumn =
    { name : ColumnName
    , owningRef : DuckDbRef
    , type_ : String
    , vals : List (Maybe Val)
    }


type alias DuckDbQueryResponse =
    { columns : List DuckDbColumn
    }


type alias DuckDbColumnDescription =
    { name : ColumnName
    , owningRef : DuckDbRef
    , type_ : String
    }


type alias DuckDbMetaResponse =
    { columnDescriptions : List DuckDbColumnDescription
    }


type alias DuckDbTableRefsResponse =
    { refs : List TableName
    }
