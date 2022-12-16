module Evergreen.V48.SheetModel exposing (..)

import Evergreen.V48.Array2D
import ISO8601


type alias CellCoords =
    ( Evergreen.V48.Array2D.RowIx, Evergreen.V48.Array2D.ColIx )


type CellElement
    = Empty
    | String_ String
    | Time_ ISO8601.Time
    | Float_ Float
    | Int_ Int
    | Bool_ Bool


type alias Cell =
    ( CellCoords, CellElement )


type alias ColumnLabel =
    String


type alias SheetEnvelope =
    { data : Evergreen.V48.Array2D.Array2D Cell
    , columnLabels : List ColumnLabel
    }


type alias RawPromptString =
    String
