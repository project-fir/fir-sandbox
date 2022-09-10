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


type alias PersistedDuckDbColumn =
    { name : ColumnName
    , owningRef : DuckDbRef
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


type alias PersistedDuckDbColumnDescription =
    { name : ColumnName
    , owningRef : DuckDbRef
    , dataType : String
    }


type alias ComputedDuckDbColumnDescription =
    { name : ColumnName
    , dataType : String
    }


type DuckDbColumnDescription
    = Persisted_ PersistedDuckDbColumnDescription
    | Computed_ ComputedDuckDbColumnDescription


type alias DuckDbMetaResponse =
    { columnDescriptions : List DuckDbColumnDescription
    }


type alias DuckDbTableRefsResponse =
    { refs : List OwningRef
    }
