module DimensionalModel exposing (CardRenderInfo, DimModelDuckDbSourceInfo, DimensionalModel, DimensionalModelEdge, DimensionalModelRef, KimballAssignment(..), NaivePairingStrategyResult(..), PositionPx, Reason(..), naiveColumnPairingStrategy)

import Dict exposing (Dict)
import DuckDb exposing (DuckDbColumnDescription(..), DuckDbRef, DuckDbRefString, DuckDbRef_(..), refToString)
import Graph exposing (Edge, Graph, Node, NodeId)
import Utils exposing (cartesian)


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : PositionPx
    , ref : DuckDb.DuckDbRef
    }


type KimballAssignment ref columns
    = Unassigned ref columns
    | Fact ref columns
    | Dimension ref columns


type alias DimensionalModelRef =
    String


type alias DimensionalModelEdge =
    ( DuckDbColumnDescription, DuckDbColumnDescription )


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict DuckDbRefString DimModelDuckDbSourceInfo
    , graph : Graph DuckDbRef_ DimensionalModelEdge
    }


type alias DimModelDuckDbSourceInfo =
    { renderInfo : CardRenderInfo
    , assignment : KimballAssignment DuckDbRef_ (List DuckDbColumnDescription)
    , isIncluded : Bool
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
        -- TODO: I can imagine some of the utility functions scoped to this let block would be useful for a broader
        --       DimensionalModel module, but for now they only have 1 use, so I'm keeping them privately scoped
        refDrillDown : DuckDbRef_ -> Maybe DuckDbRef
        refDrillDown ref =
            case ref of
                DuckDbView ref_ ->
                    Just ref_

                DuckDbTable ref_ ->
                    Just ref_

        helperFilterUnassigned : ( CardRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) ) -> Maybe DuckDbRef
        helperFilterUnassigned ( _, assignment ) =
            case assignment of
                Unassigned ref _ ->
                    refDrillDown ref

                Fact _ _ ->
                    Nothing

                Dimension _ _ ->
                    Nothing

        helperFilterFact : ( CardRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) ) -> Maybe DuckDbRef
        helperFilterFact ( _, assignment ) =
            case assignment of
                Unassigned _ _ ->
                    Nothing

                Fact ref _ ->
                    refDrillDown ref

                Dimension _ _ ->
                    Nothing

        helperFilterDimension : ( CardRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) ) -> Maybe DuckDbRef
        helperFilterDimension ( _, assignment ) =
            case assignment of
                Unassigned _ _ ->
                    Nothing

                Fact _ _ ->
                    Nothing

                Dimension ref _ ->
                    refDrillDown ref

        unassignedSources : List DuckDbRef
        unassignedSources =
            List.filterMap helperFilterUnassigned (Dict.values dimModel.tableInfos)

        factSources : List DuckDbRef
        factSources =
            List.filterMap helperFilterFact (Dict.values dimModel.tableInfos)

        dimensionSources : List DuckDbRef
        dimensionSources =
            List.filterMap helperFilterDimension (Dict.values dimModel.tableInfos)

        columnsOfNode : Node DuckDbRef_ -> List ( NodeId, DuckDbColumnDescription )
        columnsOfNode node =
            case node.label of
                DuckDbView _ ->
                    List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length []) node.id) []

                DuckDbTable ref_ ->
                    case Dict.get (refToString ref_) dimModel.tableInfos of
                        Nothing ->
                            List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length []) node.id) []

                        Just ( _, assignments ) ->
                            case assignments of
                                Unassigned _ columns ->
                                    List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length columns) node.id) columns

                                Fact _ columns ->
                                    List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length columns) node.id) columns

                                Dimension _ columns ->
                                    List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length columns) node.id) columns

        findColumnPairings : ( Node DuckDbRef_, Node DuckDbRef_ ) -> List ( ( NodeId, NodeId ), DimensionalModelEdge )
        findColumnPairings ( nodeLhs, nodeRhs ) =
            let
                combos : List ( ( NodeId, DuckDbColumnDescription ), ( NodeId, DuckDbColumnDescription ) )
                combos =
                    cartesian (columnsOfNode nodeLhs) (columnsOfNode nodeRhs)

                nameEquals : { r | name : String } -> { r | name : String } -> Bool
                nameEquals lhs rhs =
                    lhs.name == rhs.name
            in
            List.filterMap
                (\( lhs, rhs ) ->
                    case lhs of
                        ( nodeIdLhs, Persisted_ lhsDesc ) ->
                            case rhs of
                                ( nodeIdRhs, Persisted_ rhsDesc ) ->
                                    case nameEquals lhsDesc rhsDesc of
                                        True ->
                                            Just ( ( nodeIdLhs, nodeIdRhs ), ( Persisted_ lhsDesc, Persisted_ rhsDesc ) )

                                        False ->
                                            Nothing

                                ( _, Computed_ _ ) ->
                                    -- TODO: Computed column support
                                    Nothing

                        ( _, Computed_ lhsDesc ) ->
                            -- TODO: Computed column support
                            Nothing
                )
                combos

        buildGraph : Graph DuckDbRef_ DimensionalModelEdge
        buildGraph =
            let
                nodes : List (Node DuckDbRef_)
                nodes =
                    List.map2 (\src i -> Node i (DuckDbTable src))
                        (factSources ++ dimensionSources)
                        (List.range 1 (List.length (factSources ++ dimensionSources) - 1))

                nodePairs : List ( Node DuckDbRef_, Node DuckDbRef_ )
                nodePairs =
                    cartesian nodes nodes

                edges : List ( ( NodeId, NodeId ), DimensionalModelEdge )
                edges =
                    List.concatMap findColumnPairings nodePairs
            in
            Graph.fromNodesAndEdges nodes (List.map (\( ( nidL, nidR ), e ) -> Edge nidL nidR e) edges)
    in
    case List.length unassignedSources of
        0 ->
            case List.length factSources of
                0 ->
                    Fail InputMustContainAtLeastOneFactTable

                _ ->
                    case List.length dimensionSources of
                        0 ->
                            Fail InputMustContainAtLeastOneDimensionTable

                        _ ->
                            Success { dimModel | graph = buildGraph }

        _ ->
            Fail AllInputTablesMustBeAssigned
