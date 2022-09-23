module DimensionalModel exposing (DimensionalModel, DimensionalModelRef, KimballAssignment(..), NaivePairingStrategyResult(..), PositionPx, Reason(..), TableRenderInfo, naiveColumnPairingStrategy)

import Dict exposing (Dict)
import DuckDb exposing (DuckDbColumnDescription, DuckDbRef, DuckDbRefString, DuckDbRef_(..))
import Graph exposing (Graph)


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : DuckDb.DuckDbRef
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimensionalModelRef =
    String


type alias Edge =
    String


type alias DimensionalModel =
    { selectedDbRefs : List DuckDbRef
    , tableInfos :
        Dict
            DuckDbRefString
            ( TableRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) )
    , graph : Graph DuckDbRef Edge
    , ref : DimensionalModelRef
    }


type Reason
    = AllInputTablesMustBeAssigned
    | InputMustContainAtLeastOneFactTable
    | InputMustContainAtLeastOneDimensionTable


type NaivePairingStrategyResult
    = Success DimensionalModel
    | Fail Reason


naiveColumnPairingStrategy : DimensionalModel -> NaivePairingStrategyResult
naiveColumnPairingStrategy dimModel =
    let
        refDrillDown : DuckDbRef_ -> Maybe DuckDbRef
        refDrillDown ref =
            case ref of
                DuckDbView ref_ ->
                    Just ref_

                DuckDbTable ref_ ->
                    Just ref_

        helperFilterUnassigned : ( TableRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) ) -> Maybe DuckDbRef
        helperFilterUnassigned ( _, assignment ) =
            case assignment of
                Unassigned ref _ ->
                    refDrillDown ref

                Fact _ _ ->
                    Nothing

                Dimension _ _ ->
                    Nothing

        helperFilterFact : ( TableRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) ) -> Maybe DuckDbRef
        helperFilterFact ( _, assignment ) =
            case assignment of
                Unassigned _ _ ->
                    Nothing

                Fact ref _ ->
                    refDrillDown ref

                Dimension _ _ ->
                    Nothing

        helperFilterDimension : ( TableRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) ) -> Maybe DuckDbRef
        helperFilterDimension ( _, assignment ) =
            case assignment of
                Unassigned _ _ ->
                    Nothing

                Fact _ _ ->
                    Nothing

                Dimension ref _ ->
                    refDrillDown ref

        unassignedTables : List DuckDbRef
        unassignedTables =
            List.filterMap helperFilterUnassigned (Dict.values dimModel.tableInfos)

        factTables : List DuckDbRef
        factTables =
            List.filterMap helperFilterFact (Dict.values dimModel.tableInfos)

        dimensionTables : List DuckDbRef
        dimensionTables =
            List.filterMap helperFilterDimension (Dict.values dimModel.tableInfos)

        pairColumns : DimensionalModel -> DimensionalModel
        pairColumns dimModel_ =
            dimModel_
    in
    case List.length unassignedTables of
        0 ->
            case List.length factTables of
                0 ->
                    Fail InputMustContainAtLeastOneFactTable

                _ ->
                    case List.length dimensionTables of
                        0 ->
                            Fail InputMustContainAtLeastOneDimensionTable

                        _ ->
                            Success (pairColumns dimModel)

        _ ->
            Fail AllInputTablesMustBeAssigned
