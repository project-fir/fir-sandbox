module Evergreen.V21.DimensionalModel exposing (..)

import Dict
import Evergreen.V21.DuckDb
import Graph


type alias DimensionalModelRef =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V21.DuckDb.DuckDbRef
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimModelDuckDbSourceInfo =
    { renderInfo : CardRenderInfo
    , assignment : KimballAssignment Evergreen.V21.DuckDb.DuckDbRef_ (List Evergreen.V21.DuckDb.DuckDbColumnDescription)
    , isIncluded : Bool
    }


type alias DimensionalModelEdge =
    ( Evergreen.V21.DuckDb.DuckDbColumnDescription, Evergreen.V21.DuckDb.DuckDbColumnDescription )


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict.Dict Evergreen.V21.DuckDb.DuckDbRefString DimModelDuckDbSourceInfo
    , graph : Graph.Graph Evergreen.V21.DuckDb.DuckDbRef_ DimensionalModelEdge
    }
