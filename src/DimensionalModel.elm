module DimensionalModel exposing (CardRenderInfo, ColumnGraph, CommonRefEdge, DimModelDuckDbSourceInfo, DimensionalModel, DimensionalModelRef, EdgeLabel(..), JoinableEdge, KimballAssignment(..), NaivePairingStrategyResult(..), PositionPx, Reason(..), addNode, addNodes, columnGraph2DotString, naiveColumnPairingStrategy)

import Dict exposing (Dict)
import DuckDb exposing (DuckDbColumnDescription(..), DuckDbRef, DuckDbRefString, DuckDbRef_(..), refToString, ref_ToString)
import Graph exposing (Edge, Graph, Node, NodeId)
import Graph.DOT
import Hash exposing (Hash)
import IntDict


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


type alias DimensionalModel =
    { ref : DimensionalModelRef
    , tableInfos : Dict DuckDbRefString DimModelDuckDbSourceInfo
    , graph : ColumnGraph
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


assembleCommonRefSubGraph : DimensionalModel -> DimensionalModel
assembleCommonRefSubGraph dimModel =
    dimModel


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

        helperFilterUnassigned : KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) -> Maybe DuckDbRef
        helperFilterUnassigned assignment =
            case assignment of
                Unassigned ref _ ->
                    refDrillDown ref

                Fact _ _ ->
                    Nothing

                Dimension _ _ ->
                    Nothing

        helperFilterFact : KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) -> Maybe DuckDbRef
        helperFilterFact assignment =
            case assignment of
                Unassigned _ _ ->
                    Nothing

                Fact ref _ ->
                    refDrillDown ref

                Dimension _ _ ->
                    Nothing

        helperFilterDimension : KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) -> Maybe DuckDbRef
        helperFilterDimension assignment =
            case assignment of
                Unassigned _ _ ->
                    Nothing

                Fact _ _ ->
                    Nothing

                Dimension ref _ ->
                    refDrillDown ref

        includedSources : List DimModelDuckDbSourceInfo
        includedSources =
            -- TODO: Forgetting to filter out excluded source was a bug I missed, should really have test coverage on this
            --       see ticket FIR-39
            List.filterMap
                (\sourceInfo ->
                    case sourceInfo.isIncluded of
                        True ->
                            Just sourceInfo

                        False ->
                            Nothing
                )
                (Dict.values dimModel.tableInfos)

        unassignedSources : List DuckDbRef
        unassignedSources =
            -- NB: We filter on includedSources, not all source in this dimensional model!
            List.filterMap helperFilterUnassigned (List.map (\info -> info.assignment) includedSources)

        factSources : List DuckDbRef
        factSources =
            -- NB: We filter on includedSources, not all source in this dimensional model!
            List.filterMap helperFilterFact (List.map (\info -> info.assignment) includedSources)

        dimensionSources : List DuckDbRef
        dimensionSources =
            -- NB: We filter on includedSources, not all source in this dimensional model!
            List.filterMap helperFilterDimension (List.map (\info -> info.assignment) includedSources)

        columnsOfNode : Node DuckDbRef_ -> List ( NodeId, DuckDbColumnDescription )
        columnsOfNode node =
            case node.label of
                DuckDbView _ ->
                    List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length []) node.id) []

                DuckDbTable ref_ ->
                    case Dict.get (refToString ref_) dimModel.tableInfos of
                        Nothing ->
                            List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length []) node.id) []

                        Just info ->
                            case info.assignment of
                                Unassigned _ columns ->
                                    List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length columns) node.id) columns

                                Fact _ columns ->
                                    List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length columns) node.id) columns

                                Dimension _ columns ->
                                    List.map2 (\nid col -> ( nid, col )) (List.repeat (List.length columns) node.id) columns

        --findColumnPairings : ( Node DuckDbRef_, Node DuckDbRef_ ) -> List ( ( NodeId, NodeId ), EdgeLabel )
        --findColumnPairings ( nodeLhs, nodeRhs ) =
        --    let
        --        combos : List ( ( NodeId, DuckDbColumnDescription ), ( NodeId, DuckDbColumnDescription ) )
        --        combos =
        --            cartesian (columnsOfNode nodeLhs) (columnsOfNode nodeRhs)
        --
        --        nameEquals : { r | name : String } -> { r | name : String } -> Bool
        --        nameEquals lhs rhs =
        --            lhs.name == rhs.name
        --    in
        --    List.filterMap
        --        (\( lhs, rhs ) ->
        --            case lhs of
        --                ( nodeIdLhs, Persisted_ lhsDesc ) ->
        --                    case rhs of
        --                        ( nodeIdRhs, Persisted_ rhsDesc ) ->
        --                            case nameEquals lhsDesc rhsDesc of
        --                                True ->
        --                                    Just ( ( nodeIdLhs, nodeIdRhs ), ( Persisted_ lhsDesc, Persisted_ rhsDesc ) )
        --
        --                                False ->
        --                                    Nothing
        --
        --                        ( _, Computed_ _ ) ->
        --                            -- TODO: Computed column support
        --                            Nothing
        --
        --                ( _, Computed_ lhsDesc ) ->
        --                    -- TODO: Computed column support
        --                    Nothing
        --        )
        --        combos
        --
        --buildGraph : ColumnGraph
        --buildGraph =
        --    let
        --        nodes : List (Node DuckDbRef_)
        --        nodes =
        --            List.map2 (\src i -> Node i (DuckDbTable src))
        --                (factSources ++ dimensionSources)
        --                (List.range 1 (List.length (factSources ++ dimensionSources) - 1))
        --
        --        nodePairs : List ( Node DuckDbRef_, Node DuckDbRef_ )
        --        nodePairs =
        --            cartesian nodes nodes
        --
        --        edges : List ( ( NodeId, NodeId ), EdgeLabel )
        --        edges =
        --            List.concatMap findColumnPairings nodePairs
        --    in
        --    Graph.fromNodesAndEdges nodes (List.map (\( ( nidL, nidR ), e ) -> Edge nidL nidR e) edges)
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
                            --Success { dimModel | graph = buildGraph }
                            Success { dimModel | graph = Graph.empty }

        _ ->
            Fail AllInputTablesMustBeAssigned


type alias CommonRefEdge =
    Edge DuckDbRef


type alias JoinableEdge =
    Edge ()


type EdgeLabel
    = CommonRef
    | Joinable


type alias ColumnGraph =
    Graph DuckDbColumnDescription EdgeLabel


columnGraph2DotString : ColumnGraph -> String
columnGraph2DotString graph =
    let
        nodeHelper : DuckDbColumnDescription -> Maybe String
        nodeHelper n =
            case n of
                Persisted_ persistedDuckDbColumnDescription ->
                    case persistedDuckDbColumnDescription.parentRef of
                        DuckDbView ref ->
                            Just <| refToString ref ++ ":" ++ persistedDuckDbColumnDescription.name

                        DuckDbTable ref ->
                            Just <| refToString ref ++ ":" ++ persistedDuckDbColumnDescription.name

                Computed_ _ ->
                    -- TODO: Computed column support
                    Nothing

        edgeHelper : EdgeLabel -> Maybe String
        edgeHelper e =
            case e of
                CommonRef ->
                    Just "common-ref"

                Joinable ->
                    Just "joinable"
    in
    Graph.DOT.output nodeHelper edgeHelper graph


addNode : ColumnGraph -> DuckDbColumnDescription -> ColumnGraph
addNode graph node =
    let
        nodeId =
            computeNodeId node
    in
    case nodeId of
        Nothing ->
            graph

        Just nodeId_ ->
            Graph.insert
                { node = Node nodeId_ node
                , incoming = IntDict.empty
                , outgoing = IntDict.empty
                }
                graph


addNodes : ColumnGraph -> List DuckDbColumnDescription -> ColumnGraph
addNodes graph nodes =
    List.foldl (\node acc -> addNode acc node) graph nodes



--removeNode : ColumnGraph -> DuckDbColumnDescription -> ColumnGraph
-- begin region: graph utils


computeNodeId : DuckDbColumnDescription -> Maybe NodeId
computeNodeId node =
    -- TODO: I find it odd I can't unwrap Hash.Hash, but the constructors aren't exposed,
    --       so I export to string and back to int *shrug*
    case String.toInt <| Hash.toString (hashColDesc node) of
        Just hash ->
            Just <| modBy 1000000 hash

        Nothing ->
            Nothing


hashColDesc : DuckDbColumnDescription -> Hash
hashColDesc colDesc =
    case colDesc of
        Persisted_ perCol ->
            Hash.dependent
                (Hash.dependent (Hash.fromString <| ref_ToString perCol.parentRef)
                    (Hash.fromString <| perCol.name)
                )
                (Hash.fromString perCol.dataType)

        --(Hash.fromString <| perCol.dataType)
        Computed_ _ ->
            -- TODO: computed support
            Hash.fromInt 0



-- end region: graph utils
