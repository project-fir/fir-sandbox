module DimensionalModelTest exposing (..)

import Dict
import DimensionalModel exposing (DimensionalModel, KimballAssignment(..), NaivePairingStrategyResult(..), PositionPx, Reason(..), naiveColumnPairingStrategy)
import DuckDb exposing (DuckDbRef, DuckDbRef_(..), refToString)
import Expect exposing (Expectation)
import Graph
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
                (\_ -> naiveColumnPairingStrategy goodModel1 |> Expect.equal (Success goodModel1))
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
    , ref = "bad_model_3"
    }
