module Evergreen.V62.DimensionalModel exposing (..)

import Dict
import Evergreen.V62.DuckDb
import Graph


type alias DimensionalModelRef =
    String


type alias Position =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : Position
    , ref : Evergreen.V62.DuckDb.DuckDbRef
    , isDrawerOpen : Bool
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimModelDuckDbSourceInfo =
    { renderInfo : CardRenderInfo
    , assignment : KimballAssignment Evergreen.V62.DuckDb.DuckDbRef_ (List Evergreen.V62.DuckDb.DuckDbColumnDescription)
    , isIncluded : Bool
    }


type EdgeLabel lhs rhs
    = CommonRef lhs rhs
    | Joinable lhs rhs


type alias ColumnGraphEdge =
    EdgeLabel Evergreen.V62.DuckDb.DuckDbColumnDescription Evergreen.V62.DuckDb.DuckDbColumnDescription


type alias ColumnGraph =
    Graph.Graph Evergreen.V62.DuckDb.DuckDbColumnDescription ColumnGraphEdge


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict.Dict Evergreen.V62.DuckDb.DuckDbRefString DimModelDuckDbSourceInfo
    , graph : ColumnGraph
    }
