module DimensionalModelTest exposing (..)

import Dict
import DimensionalModel exposing (ColumnGraphEdge, DimModelDuckDbSourceInfo, DimensionalModel, EdgeLabel(..), KimballAssignment(..), Position)
import FirApi exposing (DuckDbColumnDescription(..), DuckDbRef, DuckDbRefString, DuckDbRef_(..), refEquals, refToString)
import Graph exposing (Edge, Node)
import Utils exposing (cartesian)



--suite : Test
--suite =
--    describe "Dimensional Model Module"
--        [ describe "Test group columns of same table"
--            [ test "happy path - case 1"
--                (\_ -> naiveColumnPairingStrategy goodModel1 |> Expect.equal (Fail InputMustContainAtLeastOneFactTable))
--
--            --, test "happy path - case 2"
--            --    (\_ -> naiveColumnPairingStrategy goodModel2 |> Expect.equal (Success goodModel2_Expected))
--            -- TODO: Test case with two facts with 1 or more column names that match should NOT result in joins
--            ]
--        ]


defaultPos : Position
defaultPos =
    -- NB: Positions shouldn't matter for things tested in these tests, so assigning
    --     all cards to be rendered to the same point shouldn't matter.
    { x = 100, y = 100 }


emptyModel : DimensionalModel
emptyModel =
    { tableInfos = Dict.empty
    , graph = Graph.empty
    , ref = "empty_model"
    }


table1 : DuckDbRef
table1 =
    { schemaName = "test"
    , tableName = "table1"
    }


table1Cols : List DuckDbColumnDescription
table1Cols =
    -- NB: We share 1 column name with a column from table2Cols, and have a few columns with unique names
    [ Persisted_
        { name = "entity_id"
        , parentRef = DuckDbTable table1
        , dataType = "DOES_NOT_MATTER_HERE"
        }
    , Persisted_
        { name = "table_1_col_a"
        , parentRef = DuckDbTable table1
        , dataType = "DOES_NOT_MATTER_HERE"
        }
    , Persisted_
        { name = "table_1_col_b"
        , parentRef = DuckDbTable table1
        , dataType = "DOES_NOT_MATTER_HERE"
        }
    ]


table2 : DuckDbRef
table2 =
    { schemaName = "test"
    , tableName = "table2"
    }


table2Cols : List DuckDbColumnDescription
table2Cols =
    -- NB: We share 1 column name with a column from table1Cols, and have a few columns with unique names
    [ Persisted_
        { name = "entity_id"
        , parentRef = DuckDbTable table2
        , dataType = "DOES_NOT_MATTER_HERE"
        }
    , Persisted_
        { name = "table_2_col_a"
        , parentRef = DuckDbTable table2
        , dataType = "DOES_NOT_MATTER_HERE"
        }
    , Persisted_
        { name = "table_2_col_b"
        , parentRef = DuckDbTable table2
        , dataType = "DOES_NOT_MATTER_HERE"
        }
    , Persisted_
        { name = "table_2_col_c"
        , parentRef = DuckDbTable table2
        , dataType = "DOES_NOT_MATTER_HERE"
        }
    ]


badModel1_ : DimensionalModel
badModel1_ =
    -- Consists of exactly 1 table which is Unassigned
    { ref = "bad_model_1"
    , tableInfos =
        Dict.fromList
            [ ( refToString table1
              , { renderInfo =
                    { pos = defaultPos
                    , ref = table1
                    , isDrawerOpen = False
                    }
                , assignment = Unassigned (DuckDbTable table1) table1Cols
                , isIncluded = True
                }
              )
            ]
    , graph = Graph.empty
    }


badModel2_ : DimensionalModel
badModel2_ =
    -- Consists of exactly 1 table which is a Fact
    { ref = "bad_model_1"
    , tableInfos =
        Dict.fromList
            [ ( refToString table1
              , { renderInfo =
                    { pos = defaultPos
                    , ref = table1
                    , isDrawerOpen = False
                    }
                , assignment = Fact (DuckDbTable table1) table1Cols
                , isIncluded = True
                }
              )
            ]
    , graph = Graph.empty
    }


badModel3_ : DimensionalModel
badModel3_ =
    -- Consists of exactly 1 table which is a Dimension
    { ref = "bad_model_1"
    , tableInfos =
        Dict.fromList
            [ ( refToString table1
              , { renderInfo =
                    { pos = defaultPos
                    , ref = table1
                    , isDrawerOpen = False
                    }
                , assignment = Dimension (DuckDbTable table1) table1Cols
                , isIncluded = True
                }
              )
            ]
    , graph = Graph.empty
    }


goodModel1 : DimensionalModel
goodModel1 =
    { ref = "good_model_1"
    , tableInfos =
        Dict.fromList
            [ ( refToString table1
              , { renderInfo =
                    { pos = defaultPos
                    , ref = table1
                    , isDrawerOpen = False
                    }
                , assignment = Fact (DuckDbTable table1) table1Cols
                , isIncluded = True
                }
              )
            , ( refToString table2
              , { renderInfo =
                    { pos = defaultPos
                    , ref = table2
                    , isDrawerOpen = False
                    }
                , assignment = Dimension (DuckDbTable table2) table2Cols
                , isIncluded = True
                }
              )
            ]
    , graph = Graph.empty
    }



--goodModel1_Expected : DimensionalModel
--goodModel1_Expected =
--    let
--        nCols1 : Int
--        nCols1 =
--            List.length table1Cols
--
--        nCols2 : Int
--        nCols2 =
--            List.length table2Cols
--
--        nodes1 : List (Node DuckDbColumnDescription)
--        nodes1 =
--            List.map2 (\col i -> { id = i, label = col }) table1Cols (List.range 1 nCols1)
--
--        nodes2 : List (Node DuckDbColumnDescription)
--        nodes2 =
--            List.map2 (\col i -> { id = i, label = col }) table1Cols (List.range (nCols1 + 1) (nCols1 + nCols2))
--
--        nodes : List (Node DuckDbColumnDescription)
--        nodes =
--            nodes1 ++ nodes2
--
--        edgesFromTable1Cols : List (Edge ColumnGraphEdge)
--        edgesFromTable1Cols =
--            List.map
--                (\( nodeLhs, nodeRhs ) ->
--                    { from = nodeLhs
--                    , to = nodeRhs
--                    , label = Joinable nodeLhs nodeRhs
--                    }
--                )
--                (cartesian nodes1 nodes1)
--
--        edgesFromTable2Cols : List (Edge ColumnGraphEdge)
--        edgesFromTable2Cols =
--            List.map
--                (\( nodeLhs, nodeRhs ) ->
--                    { from = nodeLhs.id
--                    , to = nodeRhs.id
--                    , label = Joinable nodeLhs nodeRhs
--                    }
--                )
--                (cartesian nodes2 nodes2)
--
--        edges : List (Edge ColumnGraphEdge)
--        edges =
--            edgesFromTable1Cols ++ edgesFromTable2Cols
--    in
--    { goodModel1
--        | graph = Graph.fromNodesAndEdges nodes edges
--    }
--
--
--goodModel2 : DimensionalModel
--goodModel2 =
--    let
--        dim1Ref =
--            { schemaName = "good2", tableName = "dim1" }
--
--        dim2Ref =
--            { schemaName = "good2", tableName = "dim2" }
--
--        fact1Ref =
--            { schemaName = "good2", tableName = "fact1" }
--    in
--    -- Many of the values below exist purely to make the compiler happy, but some impact the behavior we're testing
--    -- The fact table must join to each dimension table, col_b -> col_b, and col_d -> col_d
--    { tableInfos =
--        Dict.fromList
--            [ ( refToString fact1Ref
--              , ( { pos = defaultPos, ref = fact1Ref }
--                , Fact (DuckDbTable fact1Ref)
--                    [ Persisted_ { name = "col_a", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
--                    , Persisted_ { name = "col_b", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
--                    , Persisted_ { name = "col_c", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
--                    , Persisted_ { name = "col_d", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
--                    , Persisted_ { name = "col_e", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
--                    ]
--                )
--              )
--            , ( refToString dim1Ref
--              , ( { pos = defaultPos, ref = dim1Ref }
--                , Dimension (DuckDbTable dim1Ref)
--                    [ Persisted_ { name = "col_b", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
--                    , Persisted_ { name = "attr_1", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
--                    , Persisted_ { name = "attr_2", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
--                    , Persisted_ { name = "attr_3", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
--                    , Persisted_ { name = "attr_4", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
--                    ]
--                )
--              )
--            , ( refToString dim2Ref
--              , ( { pos = defaultPos, ref = dim2Ref }
--                , Dimension (DuckDbTable dim2Ref)
--                    [ Persisted_ { name = "col_d", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
--                    , Persisted_ { name = "attr_1", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
--                    , Persisted_ { name = "attr_2", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
--                    , Persisted_ { name = "attr_3", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
--                    , Persisted_ { name = "attr_4", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
--                    ]
--                )
--              )
--            ]
--    , graph = Graph.empty
--    , ref = "good_model_2"
--    }
--
--
--goodModel2_Expected : DimensionalModel
--goodModel2_Expected =
--    let
--        dim1Ref =
--            { schemaName = "good2", tableName = "dim1" }
--
--        dim2Ref =
--            { schemaName = "good2", tableName = "dim2" }
--
--        fact1Ref =
--            { schemaName = "good2", tableName = "fact1" }
--
--        nodes : List (Node DuckDbRef_)
--        nodes =
--            [ Node 1 (DuckDbTable fact1Ref)
--            , Node 2 (DuckDbTable dim1Ref)
--            , Node 3 (DuckDbTable dim2Ref)
--            ]
--
--        edges : List (Edge DimensionalModelEdge)
--        edges =
--            [ Edge 1
--                2
--                ( Persisted_ { name = "col_b", parentRef = DuckDbTable fact1Ref, dataType = "VARCHAR" }
--                , Persisted_ { name = "col_b", parentRef = DuckDbTable dim1Ref, dataType = "VARCHAR" }
--                )
--            , Edge 1
--                3
--                ( Persisted_ { name = "col_d", parentRef = DuckDbTable fact1Ref, dataType = "VARCHAR" }
--                , Persisted_ { name = "col_d", parentRef = DuckDbTable dim2Ref, dataType = "VARCHAR" }
--                )
--            ]
--
--        expectedGraph : Graph.Graph DuckDbRef_ DimensionalModelEdge
--        expectedGraph =
--            Graph.fromNodesAndEdges nodes edges
--    in
--    { goodModel2 | graph = expectedGraph }
