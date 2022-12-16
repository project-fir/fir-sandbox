module Evergreen.V48.DimensionalModel exposing (..)

import Dict
import Evergreen.V48.DuckDb
import Graph


type alias DimensionalModelRef =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V48.DuckDb.DuckDbRef
    , isDrawerOpen : Bool
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimModelDuckDbSourceInfo =
    { renderInfo : CardRenderInfo
    , assignment : KimballAssignment Evergreen.V48.DuckDb.DuckDbRef_ (List Evergreen.V48.DuckDb.DuckDbColumnDescription)
    , isIncluded : Bool
    }


type EdgeLabel
    = CommonRef
    | Joinable


type alias ColumnGraph =
    Graph.Graph Evergreen.V48.DuckDb.DuckDbColumnDescription EdgeLabel


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict.Dict Evergreen.V48.DuckDb.DuckDbRefString DimModelDuckDbSourceInfo
    , graph : ColumnGraph
    }


type Reason
    = AllInputTablesMustBeAssigned
    | InputMustContainAtLeastOneFactTable
    | InputMustContainAtLeastOneDimensionTable


type NaivePairingStrategyResult
    = Success DimensionalModel
    | Fail Reason
