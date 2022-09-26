module DimensionalModelTest exposing (..)

import Dict
import DimensionalModel exposing (DimensionalModel, DimensionalModelEdge, KimballAssignment(..), NaivePairingStrategyResult(..), PositionPx, Reason(..), naiveColumnPairingStrategy)
import DuckDb exposing (DuckDbColumnDescription(..), DuckDbRef, DuckDbRef_(..), refToString)
import Expect exposing (Expectation)
import Graph exposing (Edge, Node)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Dimensional Model Module"
        [ describe "malformed input yields appropriate result"
            [ test "input dimModel must have no 'Unassigned' tables"
                (\_ -> naiveColumnPairingStrategy badModel1 |> Expect.equal (Fail AllInputTablesMustBeAssigned))
            , test "input dimModel must have at least one 'Dimension' table"
                (\_ -> naiveColumnPairingStrategy badModel2 |> Expect.equal (Fail InputMustContainAtLeastOneDimensionTable))
            , test "input dimModel must have at least one 'Fact' table"
                (\_ -> naiveColumnPairingStrategy badModel3 |> Expect.equal (Fail InputMustContainAtLeastOneFactTable))
            , test "fail nicely if given empty input"
                (\_ -> naiveColumnPairingStrategy emptyModel |> Expect.equal (Fail InputMustContainAtLeastOneFactTable))
            ]
        , describe "Good input yields graph built using naive pairing strategy"
            [ test "happy path - case 1. Degenerate case: tables are assigned, but there are no columns, so we do nothing"
                (\_ -> naiveColumnPairingStrategy goodModel1 |> Expect.equal (Success goodModel1_Expected))

            --, test "happy path - case 2. Single fact table with two dimensions, with two columns that should result in graph edges"
            --    (\_ -> naiveColumnPairingStrategy goodModel2 |> Expect.equal (Success goodModel2_Expected))
            ]
        ]


defaultPos : PositionPx
defaultPos =
    { x = 100, y = 100 }


defaultRef : DuckDbRef
defaultRef =
    { schemaName = "test", tableName = "test_table" }


emptyModel : DimensionalModel
emptyModel =
    { selectedDbRefs = []
    , tableInfos = Dict.empty
    , graph = Graph.empty
    , ref = "empty_model"
    }


badModel1 : DimensionalModel
badModel1 =
    -- This model has an Unassigned table in it
    { selectedDbRefs = []
    , tableInfos =
        Dict.fromList
            [ ( refToString defaultRef, ( { pos = defaultPos, ref = defaultRef }, Unassigned (DuckDbTable defaultRef) [] ) )
            ]
    , graph = Graph.empty
    , ref = "bad_model_1"
    }


badModel2 : DimensionalModel
badModel2 =
    -- This model is missing a Dimension table
    { selectedDbRefs = []
    , tableInfos =
        Dict.fromList
            [ ( refToString defaultRef, ( { pos = defaultPos, ref = defaultRef }, Fact (DuckDbTable defaultRef) [] ) )
            ]
    , graph = Graph.empty
    , ref = "bad_model_2"
    }


badModel3 : DimensionalModel
badModel3 =
    -- This model is missing a Fact table
    { selectedDbRefs = []
    , tableInfos =
        Dict.fromList
            [ ( refToString defaultRef, ( { pos = defaultPos, ref = defaultRef }, Dimension (DuckDbTable defaultRef) [] ) )
            ]
    , graph = Graph.empty
    , ref = "bad_model_3"
    }


goodModel1 : DimensionalModel
goodModel1 =
    { selectedDbRefs = []
    , tableInfos =
        Dict.fromList
            [ ( refToString { schemaName = "happy_path", tableName = "dim1" }, ( { pos = defaultPos, ref = defaultRef }, Dimension (DuckDbTable defaultRef) [] ) )
            , ( refToString { schemaName = "happy_path", tableName = "fact1" }, ( { pos = defaultPos, ref = defaultRef }, Fact (DuckDbTable defaultRef) [] ) )
            ]
    , graph = Graph.empty
    , ref = "good_model_1"
    }


goodModel1_Expected : DimensionalModel
goodModel1_Expected =
    { selectedDbRefs = []
    , tableInfos =
        Dict.fromList
            [ ( refToString { schemaName = "happy_path", tableName = "dim1" }, ( { pos = defaultPos, ref = defaultRef }, Dimension (DuckDbTable defaultRef) [] ) )
            , ( refToString { schemaName = "happy_path", tableName = "fact1" }, ( { pos = defaultPos, ref = defaultRef }, Fact (DuckDbTable defaultRef) [] ) )
            ]
    , graph =
        Graph.fromNodesAndEdges
            [ Node 1 (DuckDbTable { schemaName = "happy_path", tableName = "dim1" })
            , Node 2 (DuckDbTable { schemaName = "happy_path", tableName = "fact1" })
            ]
            []
    , ref = "good_model_1"
    }


goodModel2 : DimensionalModel
goodModel2 =
    -- Many of the values below exist purely to make the compiler happy, but some impact the behavior we're testing
    -- The fact table must join to each dimension table, col_b -> col_b, and col_d -> col_d
    { selectedDbRefs = []
    , tableInfos =
        Dict.fromList
            [ ( refToString { schemaName = "good_2", tableName = "fact1" }
              , ( { pos = defaultPos, ref = defaultRef }
                , Fact (DuckDbTable { schemaName = "happy_path", tableName = "fact1" })
                    [ Persisted_ { name = "col_a", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "fact1" } }
                    , Persisted_ { name = "col_b", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "fact1" } }
                    , Persisted_ { name = "col_c", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "fact1" } }
                    , Persisted_ { name = "col_d", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "fact1" } }
                    , Persisted_ { name = "col_e", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "fact1" } }
                    ]
                )
              )
            , ( refToString { schemaName = "good_2", tableName = "dim1" }
              , ( { pos = defaultPos, ref = defaultRef }
                , Dimension (DuckDbTable { schemaName = "happy_path", tableName = "dim1" })
                    [ Persisted_ { name = "col_b", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim1" } }
                    , Persisted_ { name = "attr_1", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim1" } }
                    , Persisted_ { name = "attr_2", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim1" } }
                    , Persisted_ { name = "attr_3", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim1" } }
                    , Persisted_ { name = "attr_4", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim1" } }
                    ]
                )
              )
            , ( refToString { schemaName = "good_2", tableName = "dim2" }
              , ( { pos = defaultPos, ref = defaultRef }
                , Dimension (DuckDbTable { schemaName = "happy_path", tableName = "dim2" })
                    [ Persisted_ { name = "col_d", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim2" } }
                    , Persisted_ { name = "attr_1", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim2" } }
                    , Persisted_ { name = "attr_2", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim2" } }
                    , Persisted_ { name = "attr_3", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim2" } }
                    , Persisted_ { name = "attr_4", dataType = "VARCHAR", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim2" } }
                    ]
                )
              )
            ]
    , graph = Graph.empty
    , ref = "good_model_2"
    }


goodModel2_Expected : DimensionalModel
goodModel2_Expected =
    let
        nodes : List (Node DuckDbRef_)
        nodes =
            [ Node 1 (DuckDbTable { schemaName = "happy_path", tableName = "fact1" })
            , Node 2 (DuckDbTable { schemaName = "happy_path", tableName = "dim1" })
            , Node 3 (DuckDbTable { schemaName = "happy_path", tableName = "dim2" })
            ]

        edges : List (Edge DimensionalModelEdge)
        edges =
            [ Edge 1
                2
                ( Persisted_ { name = "col_b", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "fact1" }, dataType = "VARCHAR" }
                , Persisted_ { name = "col_b", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim1" }, dataType = "VARCHAR" }
                )
            , Edge 1
                3
                ( Persisted_ { name = "col_d", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "fact1" }, dataType = "VARCHAR" }
                , Persisted_ { name = "col_d", parentRef = DuckDbTable { schemaName = "happy_path", tableName = "dim2" }, dataType = "VARCHAR" }
                )
            ]

        expectedGraph : Graph.Graph DuckDbRef_ DimensionalModelEdge
        expectedGraph =
            Graph.fromNodesAndEdges nodes edges
    in
    { goodModel2 | graph = expectedGraph }
