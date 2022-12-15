module Evergreen.V46.History exposing (..)


type alias InternalHistory a =
    { past : List a
    , future : List a
    }


type History a
    = History (InternalHistory a)
