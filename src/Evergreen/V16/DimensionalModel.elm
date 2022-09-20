module Evergreen.V16.DimensionalModel exposing (..)

import Dict
import Evergreen.V16.DuckDb
import Graph


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V16.DuckDb.DuckDbRef
    }


type alias DimensionalModelRef =
    String


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias Edge =
    String


type alias DimensionalModel =
    { selectedDbRefs : List Evergreen.V16.DuckDb.DuckDbRef
    , tableInfos : Dict.Dict Evergreen.V16.DuckDb.DuckDbRefString ( TableRenderInfo, KimballAssignment Evergreen.V16.DuckDb.DuckDbRef_ (List Evergreen.V16.DuckDb.DuckDbColumnDescription) )
    , graph : Graph.Graph Evergreen.V16.DuckDb.DuckDbRef Edge
    , ref : DimensionalModelRef
    }
