module Evergreen.V65.DimensionalModel exposing (..)

import Dict
import Evergreen.V65.FirApi
import Graph


type alias DimensionalModelRef =
    String


type alias Position =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : Position
    , ref : Evergreen.V65.FirApi.DuckDbRef
    , isDrawerOpen : Bool
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimModelDuckDbSourceInfo =
    { renderInfo : CardRenderInfo
    , assignment : KimballAssignment Evergreen.V65.FirApi.DuckDbRef_ (List Evergreen.V65.FirApi.DuckDbColumnDescription)
    , isIncluded : Bool
    }


type EdgeLabel lhs rhs
    = CommonRef lhs rhs
    | Joinable lhs rhs


type alias ColumnGraphEdge =
    EdgeLabel Evergreen.V65.FirApi.DuckDbColumnDescription Evergreen.V65.FirApi.DuckDbColumnDescription


type alias ColumnGraph =
    Graph.Graph Evergreen.V65.FirApi.DuckDbColumnDescription ColumnGraphEdge


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict.Dict Evergreen.V65.FirApi.DuckDbRefString DimModelDuckDbSourceInfo
    , graph : ColumnGraph
    }
