module Evergreen.V17.DimensionalModel exposing (..)

import Dict
import Evergreen.V17.DuckDb
import Graph


type alias DimensionalModelRef =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V17.DuckDb.DuckDbRef
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias Edge =
    String


type alias DimensionalModel =
    { selectedDbRefs : List Evergreen.V17.DuckDb.DuckDbRef
    , tableInfos : Dict.Dict Evergreen.V17.DuckDb.DuckDbRefString ( TableRenderInfo, KimballAssignment Evergreen.V17.DuckDb.DuckDbRef_ (List Evergreen.V17.DuckDb.DuckDbColumnDescription) )
    , graph : Graph.Graph Evergreen.V17.DuckDb.DuckDbRef Edge
    , ref : DimensionalModelRef
    }
