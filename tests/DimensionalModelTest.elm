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
            [ test "happy path - case 1"
                (\_ -> naiveColumnPairingStrategy goodModel1 |> Expect.equal (Success goodModel1_Expected))
            , test "happy path - case 2"
                (\_ -> naiveColumnPairingStrategy goodModel2 |> Expect.equal (Success goodModel2_Expected))

            -- TODO: Test case with two facts with 1 or more column names that match should NOT result in joins
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
    { tableInfos = Dict.empty
    , graph = Graph.empty
    , ref = "empty_model"
    }


badModel1 : DimensionalModel
badModel1 =
    -- This model has an Unassigned table in it
    { tableInfos =
        Dict.fromList
            [ ( refToString defaultRef, ( { pos = defaultPos, ref = defaultRef }, Unassigned (DuckDbTable defaultRef) [] ) )
            ]
    , graph = Graph.empty
    , ref = "bad_model_1"
    }


badModel2 : DimensionalModel
badModel2 =
    -- This model is missing a Dimension table
    { tableInfos =
        Dict.fromList
            [ ( refToString defaultRef, ( { pos = defaultPos, ref = defaultRef }, Fact (DuckDbTable defaultRef) [] ) )
            ]
    , graph = Graph.empty
    , ref = "bad_model_2"
    }


badModel3 : DimensionalModel
badModel3 =
    -- This model is missing a Fact table
    { tableInfos =
        Dict.fromList
            [ ( refToString defaultRef, ( { pos = defaultPos, ref = defaultRef }, Dimension (DuckDbTable defaultRef) [] ) )
            ]
    , graph = Graph.empty
    , ref = "bad_model_3"
    }


goodModel1 : DimensionalModel
goodModel1 =
    let
        dim1Ref =
            { schemaName = "good1", tableName = "dim1" }

        fact1Ref =
            { schemaName = "good1", tableName = "fact1" }
    in
    { tableInfos =
        Dict.fromList
            [ ( refToString dim1Ref, ( { pos = defaultPos, ref = dim1Ref }, Dimension (DuckDbTable dim1Ref) [] ) )
            , ( refToString fact1Ref, ( { pos = defaultPos, ref = fact1Ref }, Fact (DuckDbTable fact1Ref) [] ) )
            ]
    , graph = Graph.empty
    , ref = "good_model_1"
    }


goodModel1_Expected : DimensionalModel
goodModel1_Expected =
    let
        dim1Ref =
            { schemaName = "good1", tableName = "dim1" }

        fact1Ref =
            { schemaName = "good1", tableName = "fact1" }
    in
    { tableInfos =
        Dict.fromList
            [ ( refToString dim1Ref, ( { pos = defaultPos, ref = dim1Ref }, Dimension (DuckDbTable dim1Ref) [] ) )
            , ( refToString fact1Ref, ( { pos = defaultPos, ref = fact1Ref }, Fact (DuckDbTable fact1Ref) [] ) )
            ]
    , graph =
        Graph.fromNodesAndEdges
            [ Node 1 (DuckDbTable dim1Ref)
            , Node 2 (DuckDbTable fact1Ref)
            ]
            []
    , ref = "good_model_1"
    }


goodModel2 : DimensionalModel
goodModel2 =
    let
        dim1Ref =
            { schemaName = "good2", tableName = "dim1" }

        dim2Ref =
            { schemaName = "good2", tableName = "dim2" }

        fact1Ref =
            { schemaName = "good2", tableName = "fact1" }
    in
    -- Many of the values below exist purely to make the compiler happy, but some impact the behavior we're testing
    -- The fact table must join to each dimension table, col_b -> col_b, and col_d -> col_d
    { tableInfos =
        Dict.fromList
            [ ( refToString fact1Ref
              , ( { pos = defaultPos, ref = fact1Ref }
                , Fact (DuckDbTable fact1Ref)
                    [ Persisted_ { name = "col_a", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
                    , Persisted_ { name = "col_b", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
                    , Persisted_ { name = "col_c", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
                    , Persisted_ { name = "col_d", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
                    , Persisted_ { name = "col_e", dataType = "VARCHAR", parentRef = DuckDbTable fact1Ref }
                    ]
                )
              )
            , ( refToString dim1Ref
              , ( { pos = defaultPos, ref = dim1Ref }
                , Dimension (DuckDbTable dim1Ref)
                    [ Persisted_ { name = "col_b", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
                    , Persisted_ { name = "attr_1", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
                    , Persisted_ { name = "attr_2", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
                    , Persisted_ { name = "attr_3", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
                    , Persisted_ { name = "attr_4", dataType = "VARCHAR", parentRef = DuckDbTable dim1Ref }
                    ]
                )
              )
            , ( refToString dim2Ref
              , ( { pos = defaultPos, ref = dim2Ref }
                , Dimension (DuckDbTable dim2Ref)
                    [ Persisted_ { name = "col_d", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
                    , Persisted_ { name = "attr_1", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
                    , Persisted_ { name = "attr_2", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
                    , Persisted_ { name = "attr_3", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
                    , Persisted_ { name = "attr_4", dataType = "VARCHAR", parentRef = DuckDbTable dim2Ref }
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
        dim1Ref =
            { schemaName = "good2", tableName = "dim1" }

        dim2Ref =
            { schemaName = "good2", tableName = "dim2" }

        fact1Ref =
            { schemaName = "good2", tableName = "fact1" }

        nodes : List (Node DuckDbRef_)
        nodes =
            [ Node 1 (DuckDbTable fact1Ref)
            , Node 2 (DuckDbTable dim1Ref)
            , Node 3 (DuckDbTable dim2Ref)
            ]

        edges : List (Edge DimensionalModelEdge)
        edges =
            [ Edge 1
                2
                ( Persisted_ { name = "col_b", parentRef = DuckDbTable fact1Ref, dataType = "VARCHAR" }
                , Persisted_ { name = "col_b", parentRef = DuckDbTable dim1Ref, dataType = "VARCHAR" }
                )
            , Edge 1
                3
                ( Persisted_ { name = "col_d", parentRef = DuckDbTable fact1Ref, dataType = "VARCHAR" }
                , Persisted_ { name = "col_d", parentRef = DuckDbTable dim2Ref, dataType = "VARCHAR" }
                )
            ]

        expectedGraph : Graph.Graph DuckDbRef_ DimensionalModelEdge
        expectedGraph =
            Graph.fromNodesAndEdges nodes edges
    in
    { goodModel2 | graph = expectedGraph }
