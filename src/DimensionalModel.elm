module DimensionalModel exposing
    ( CardRenderInfo
    , ColumnGraph
    , CommonRefEdge
    , DimModelDuckDbSourceInfo
    , DimensionalModel
    , DimensionalModelRef
    , EdgeLabel(..)
    , JoinableEdge
    , KimballAssignment(..)
    , NaivePairingStrategyResult(..)
    , PositionPx
    , Reason(..)
    , addEdge
    , addEdges
    , addNode
    , addNodes
    , columnDescFromNodeId
    , columnGraph2DotString
    , edge2Str
    , edgesOfType
    , unpackAssignment
    )

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
    , isDrawerOpen : Bool
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
    -- TODO: Should I unfold CardRenderInfo into this record type?
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


type alias CommonRefEdge =
    Edge DuckDbRef


type alias JoinableEdge =
    Edge ()


type EdgeLabel
    = CommonRef
    | Joinable


type alias ColumnGraph =
    Graph DuckDbColumnDescription EdgeLabel


columnDescFromNodeId : ColumnGraph -> NodeId -> Maybe DuckDbColumnDescription
columnDescFromNodeId graph nodeId =
    case Graph.get nodeId graph of
        Just a ->
            Just a.node.label

        Nothing ->
            Nothing


columnGraph2DotString : ColumnGraph -> String
columnGraph2DotString graph =
    -- Note: Intended for dev/debug use only! A lot is lost when translating to a string, so features should not be
    --       powered by the output of this function!
    let
        nodeHelper : DuckDbColumnDescription -> Maybe String
        nodeHelper n =
            case n of
                Persisted_ persistedDuckDbColumnDescription ->
                    case persistedDuckDbColumnDescription.parentRef of
                        DuckDbTable ref ->
                            Just <| refToString ref ++ ":" ++ persistedDuckDbColumnDescription.name

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
    case computeNodeId node of
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
    -- TODO: Test
    List.foldl (\node acc -> addNode acc node) graph nodes


addEdges : ColumnGraph -> List ( DuckDbColumnDescription, DuckDbColumnDescription, EdgeLabel ) -> ColumnGraph
addEdges graph edges =
    -- TODO: Test
    List.foldl (\( lhs, rhs, lbl ) acc -> addEdge acc ( lhs, rhs ) lbl) graph edges


addEdge : ColumnGraph -> ( DuckDbColumnDescription, DuckDbColumnDescription ) -> EdgeLabel -> ColumnGraph
addEdge graph ( lhs, rhs ) lbl =
    let
        insertEdge : Edge EdgeLabel -> ColumnGraph -> ColumnGraph
        insertEdge edge =
            Graph.update edge.from
                (\maybeCtx ->
                    case maybeCtx of
                        Nothing ->
                            Nothing

                        Just ctx ->
                            Just { ctx | outgoing = IntDict.insert edge.to edge.label ctx.outgoing }
                )

        lhsId : Maybe NodeId
        lhsId =
            computeNodeId lhs

        rhsId : Maybe NodeId
        rhsId =
            computeNodeId rhs
    in
    case lhsId of
        Just lhsId_ ->
            case rhsId of
                Just rhsId_ ->
                    insertEdge { from = lhsId_, to = rhsId_, label = lbl } graph

                Nothing ->
                    graph

        Nothing ->
            graph



-- removeNode : ColumnGraph -> DuckDbColumnDescription -> ColumnGraph
-- begin region: graph utils


computeNodeId : DuckDbColumnDescription -> Maybe NodeId
computeNodeId node =
    -- TODO: Test
    -- TODO: I find it odd I can't unwrap Hash.Hash, but the constructors aren't exposed,
    --       so I export to string and back to int *shrug*
    case String.toInt <| Hash.toString (hashColDesc node) of
        Just hash ->
            -- HACK: The DOT web viewer doesn't support Elm's scientific notation for large Ints represented as Strings
            --       so, modBy a ten million to avoid that. This is for `/admin` page viewing only, so I think I can live with this
            Just <| modBy 10000000 hash

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


edgesOfType : ColumnGraph -> EdgeLabel -> List (Edge EdgeLabel)
edgesOfType graph label =
    List.filter
        (\e ->
            if e.label == label then
                True

            else
                False
        )
        (Graph.edges graph)


edge2Str : Edge EdgeLabel -> String
edge2Str e =
    String.fromInt e.from
        ++ "--"
        ++ (case e.label of
                CommonRef ->
                    "common-ref"

                Joinable ->
                    "joinable"
           )
        ++ "->"
        ++ String.fromInt e.to



-- end region: graph utils
-- begin region: misc. utils


unpackAssignment : KimballAssignment ref columns -> ( ref, columns )
unpackAssignment assignment =
    case assignment of
        Unassigned ref colDescs ->
            ( ref, colDescs )

        Fact ref colDescs ->
            ( ref, colDescs )

        Dimension ref colDescs ->
            ( ref, colDescs )



-- end region: misc. utils
