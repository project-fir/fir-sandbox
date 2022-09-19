module DimensionalModel exposing (DimensionalModel, DimensionalModelRef, PositionPx, TableRenderInfo)

import Dict exposing (Dict)
import DuckDb exposing (DuckDbRef, DuckDbRefString)
import Graph exposing (Graph)


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


type alias Edge =
    String


type alias DimensionalModel =
    { selectedDbRefs : List DuckDbRef
    , renderInfos : Dict DuckDbRefString TableRenderInfo
    , graph : Graph DuckDbRef Edge
    , ref : DimensionalModelRef
    }
