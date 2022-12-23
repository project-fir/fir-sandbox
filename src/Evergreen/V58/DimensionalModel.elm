module Evergreen.V58.DimensionalModel exposing (..)

import Dict
import Evergreen.V58.DuckDb
import Graph


type alias DimensionalModelRef =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V58.DuckDb.DuckDbRef
    , isDrawerOpen : Bool
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimModelDuckDbSourceInfo =
    { renderInfo : CardRenderInfo
    , assignment : KimballAssignment Evergreen.V58.DuckDb.DuckDbRef_ (List Evergreen.V58.DuckDb.DuckDbColumnDescription)
    , isIncluded : Bool
    }


type EdgeLabel lhs rhs
    = CommonRef lhs rhs
    | Joinable lhs rhs


type alias ColumnGraphEdge =
    EdgeLabel Evergreen.V58.DuckDb.DuckDbColumnDescription Evergreen.V58.DuckDb.DuckDbColumnDescription


type alias ColumnGraph =
    Graph.Graph Evergreen.V58.DuckDb.DuckDbColumnDescription ColumnGraphEdge


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict.Dict Evergreen.V58.DuckDb.DuckDbRefString DimModelDuckDbSourceInfo
    , graph : ColumnGraph
    }
