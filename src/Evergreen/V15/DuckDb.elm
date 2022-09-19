module Evergreen.V15.DuckDb exposing (..)

import ISO8601


type alias SchemaName =
    String


type alias TableName =
    String


type alias DuckDbRef =
    { schemaName : SchemaName
    , tableName : TableName
    }


type alias DuckDbRefsResponse =
    { refs : List DuckDbRef
    }


type DuckDbRef_
    = View DuckDbRef
    | Table DuckDbRef


type alias ColumnName =
    String


type alias PersistedDuckDbColumnDescription =
    { name : ColumnName
    , parentRef : DuckDbRef_
    , dataType : String
    }


type alias ComputedDuckDbColumnDescription =
    { name : ColumnName
    , dataType : String
    }


type DuckDbColumnDescription
    = Persisted_ PersistedDuckDbColumnDescription
    | Computed_ ComputedDuckDbColumnDescription


type Val
    = Varchar_ String
    | Time_ ISO8601.Time
    | Bool_ Bool
    | Float_ Float
    | Int_ Int
    | Unknown


type alias PersistedDuckDbColumn =
    { name : ColumnName
    , parentRef : DuckDbRef_
    , dataType : String
    , vals : List (Maybe Val)
    }


type alias ComputedDuckDbColumn =
    { name : ColumnName
    , dataType : String
    , vals : List (Maybe Val)
    }


type DuckDbColumn
    = Persisted PersistedDuckDbColumn
    | Computed ComputedDuckDbColumn


type alias DuckDbQueryResponse =
    { columns : List DuckDbColumn
    }


type alias DuckDbMetaResponse =
    { columnDescriptions : List DuckDbColumnDescription
    }
