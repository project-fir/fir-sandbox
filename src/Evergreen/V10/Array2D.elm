module Evergreen.V10.Array2D exposing (..)

import Array


type alias RowIx =
    Int


type alias ColIx =
    Int


type alias Array2D e =
    Array.Array (Array.Array e)
