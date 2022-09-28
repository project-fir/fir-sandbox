module Evergreen.V22.DimensionalModel exposing (..)

import Dict
import Evergreen.V22.DuckDb
import Graph


type alias DimensionalModelRef =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V22.DuckDb.DuckDbRef
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimModelDuckDbSourceInfo =
    { renderInfo : CardRenderInfo
    , assignment : KimballAssignment Evergreen.V22.DuckDb.DuckDbRef_ (List Evergreen.V22.DuckDb.DuckDbColumnDescription)
    , isIncluded : Bool
    }


type alias DimensionalModelEdge =
    ( Evergreen.V22.DuckDb.DuckDbColumnDescription, Evergreen.V22.DuckDb.DuckDbColumnDescription )


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict.Dict Evergreen.V22.DuckDb.DuckDbRefString DimModelDuckDbSourceInfo
    , graph : Graph.Graph Evergreen.V22.DuckDb.DuckDbRef_ DimensionalModelEdge
    }


type Reason
    = AllInputTablesMustBeAssigned
    | InputMustContainAtLeastOneFactTable
    | InputMustContainAtLeastOneDimensionTable


type NaivePairingStrategyResult
    = Success DimensionalModel
    | Fail Reason
