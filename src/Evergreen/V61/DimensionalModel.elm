module Evergreen.V61.DimensionalModel exposing (..)

import Dict
import Evergreen.V61.DuckDb
import Graph


type alias DimensionalModelRef =
    String


type alias Position =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : Position
    , ref : Evergreen.V61.DuckDb.DuckDbRef
    , isDrawerOpen : Bool
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimModelDuckDbSourceInfo =
    { renderInfo : CardRenderInfo
    , assignment : KimballAssignment Evergreen.V61.DuckDb.DuckDbRef_ (List Evergreen.V61.DuckDb.DuckDbColumnDescription)
    , isIncluded : Bool
    }


type EdgeLabel lhs rhs
    = CommonRef lhs rhs
    | Joinable lhs rhs


type alias ColumnGraphEdge =
    EdgeLabel Evergreen.V61.DuckDb.DuckDbColumnDescription Evergreen.V61.DuckDb.DuckDbColumnDescription


type alias ColumnGraph =
    Graph.Graph Evergreen.V61.DuckDb.DuckDbColumnDescription ColumnGraphEdge


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict.Dict Evergreen.V61.DuckDb.DuckDbRefString DimModelDuckDbSourceInfo
    , graph : ColumnGraph
    }
