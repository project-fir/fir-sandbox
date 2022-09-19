module DimensionalModel exposing (DimensionalModel, DimensionalModelRef, PositionPx, TableRenderInfo)

import Dict exposing (Dict)
import DuckDb exposing (DuckDbRef, DuckDbRefString)


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : DuckDb.DuckDbRef
    }


type alias DimensionalModelRef =
    String


type alias DimensionalModel =
    { selectedTables : List DuckDbRef
    , renderInfos : Dict DuckDbRefString TableRenderInfo
    }
