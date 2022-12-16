module Evergreen.V52.DuckDb exposing (..)

import ISO8601


type alias DuckDbRefString =
    String


type alias SchemaName =
    String


type alias TableName =
    String


type alias DuckDbRef =
    { schemaName : SchemaName
    , tableName : TableName
    }


type DuckDbRef_
    = DuckDbTable DuckDbRef


type alias ColumnName =
    String


type alias PersistedDuckDbColumnDescription =
    { name : ColumnName
    , parentRef : DuckDbRef_
    , dataType : String
    }


type DuckDbColumnDescription
    = Persisted_ PersistedDuckDbColumnDescription


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


type DuckDbColumn
    = Persisted PersistedDuckDbColumn


type alias DuckDbQueryResponse =
    { columns : List DuckDbColumn
    }


type alias DuckDbMetaResponse =
    { columnDescriptions : List DuckDbColumnDescription
    , refs : List DuckDbRef
    }


type alias DuckDbRefsResponse =
    { refs : List DuckDbRef
    }


type alias PingResponse =
    { message : String
    }
