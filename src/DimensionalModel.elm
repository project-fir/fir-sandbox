module DimensionalModel exposing (DimensionalModel, DimensionalModelRef, KimballAssignment(..), PositionPx, TableRenderInfo)

import Dict exposing (Dict)
import DuckDb exposing (DuckDbColumnDescription, DuckDbRef, DuckDbRefString, DuckDbRef_)
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
