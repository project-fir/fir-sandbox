module Evergreen.V49.DimensionalModel exposing (..)

import Dict
import Evergreen.V49.DuckDb
import Graph


type alias DimensionalModelRef =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V49.DuckDb.DuckDbRef
    , isDrawerOpen : Bool
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimModelDuckDbSourceInfo =
    { renderInfo : CardRenderInfo
    , assignment : KimballAssignment Evergreen.V49.DuckDb.DuckDbRef_ (List Evergreen.V49.DuckDb.DuckDbColumnDescription)
    , isIncluded : Bool
    }


type EdgeLabel
    = CommonRef
    | Joinable


type alias ColumnGraph =
    Graph.Graph Evergreen.V49.DuckDb.DuckDbColumnDescription EdgeLabel


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict.Dict Evergreen.V49.DuckDb.DuckDbRefString DimModelDuckDbSourceInfo
    , graph : ColumnGraph
    }


type Reason
    = AllInputTablesMustBeAssigned
    | InputMustContainAtLeastOneFactTable
    | InputMustContainAtLeastOneDimensionTable


type NaivePairingStrategyResult
    = Success DimensionalModel
    | Fail Reason
