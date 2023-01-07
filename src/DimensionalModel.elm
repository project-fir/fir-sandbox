module DimensionalModel exposing
    ( CardRenderInfo
    , ColumnGraph
    , ColumnGraphEdge
    , CommonRefEdge
    , DimModelDuckDbSourceInfo
    , DimensionalModel
    , DimensionalModelRef
    , EdgeFamily(..)
    , EdgeLabel(..)
    , JoinableEdge
    , KimballAssignment(..)
    , LineSegment
    , Position
    , addEdge
    , addEdges
    , addNode
    , addNodes
    , columnDescFromNodeId
    , columnGraph2DotString
    , edge2Str
    , edgesOfFamily
    , unpackKimballAssignment
    )

import Dict exposing (Dict)
import FirApi exposing (DuckDbColumnDescription, DuckDbRef, DuckDbRefString, DuckDbRef_(..), refToString, ref_ToString)
import Graph exposing (Edge, Graph, Node, NodeId)
import Graph.DOT
import Hash exposing (Hash)
import IntDict


type alias LineSegment =
    ( Position, Position )


type alias Position =
    { x : Float
    , y : Float
    }


type alias CardRenderInfo =
    { pos : Position
    , ref : FirApi.DuckDbRef
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


type alias CommonRefEdge =
    Edge DuckDbRef


type alias JoinableEdge =
    Edge ()


type EdgeLabel lhs rhs
    = CommonRef lhs rhs
    | Joinable lhs rhs


type EdgeFamily
    = CommonRef_
    | Joinable_


type alias ColumnGraphEdge =
    EdgeLabel DuckDbColumnDescription DuckDbColumnDescription


type alias ColumnGraph =
    Graph DuckDbColumnDescription ColumnGraphEdge


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
        nodeHelper colDesc =
            case colDesc.parentRef of
                DuckDbTable ref ->
                    Just <| refToString ref ++ ":" ++ colDesc.name

        edgeHelper : ColumnGraphEdge -> Maybe String
        edgeHelper e =
            case e of
                CommonRef _ _ ->
                    Just "common-ref"

                Joinable _ _ ->
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


addEdges : ColumnGraph -> List ( DuckDbColumnDescription, DuckDbColumnDescription, ColumnGraphEdge ) -> ColumnGraph
addEdges graph edges =
    -- TODO: Test
    List.foldl (\( lhs, rhs, lbl ) acc -> addEdge acc ( lhs, rhs ) lbl) graph edges


addEdge : ColumnGraph -> ( DuckDbColumnDescription, DuckDbColumnDescription ) -> ColumnGraphEdge -> ColumnGraph
addEdge graph ( lhs, rhs ) lbl =
    let
        insertEdge : Edge ColumnGraphEdge -> ColumnGraph -> ColumnGraph
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
    Hash.dependent
        (Hash.dependent (Hash.fromString <| ref_ToString colDesc.parentRef)
            (Hash.fromString <| colDesc.name)
        )
        (Hash.fromString colDesc.dataType)


edgesOfFamily : ColumnGraph -> EdgeFamily -> List (Edge ColumnGraphEdge)
edgesOfFamily graph family =
    case family of
        CommonRef_ ->
            List.filter
                (\e ->
                    case e.label of
                        CommonRef _ _ ->
                            True

                        Joinable _ _ ->
                            False
                )
                (Graph.edges graph)

        Joinable_ ->
            List.filter
                (\e ->
                    case e.label of
                        Joinable _ _ ->
                            True

                        CommonRef _ _ ->
                            False
                )
                (Graph.edges graph)


edge2Str : Edge ColumnGraphEdge -> String
edge2Str e =
    String.fromInt e.from
        ++ "--"
        ++ (case e.label of
                -- TODO: Where is this used? Do I want to include lhs rhs in the debug str?
                CommonRef lhs rhs ->
                    "common-ref"

                Joinable lhs rhs ->
                    "joinable"
           )
        ++ "->"
        ++ String.fromInt e.to



-- end region: graph utils
-- begin region: misc. utils


unpackKimballAssignment : KimballAssignment ref columns -> ( ref, columns )
unpackKimballAssignment assignment =
    case assignment of
        Unassigned ref colDescs ->
            ( ref, colDescs )

        Fact ref colDescs ->
            ( ref, colDescs )

        Dimension ref colDescs ->
            ( ref, colDescs )



-- end region: misc. utils
