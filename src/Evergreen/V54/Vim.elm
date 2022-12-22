module Evergreen.V54.Vim exposing (..)


type VState
    = VAccumulate
    | VNormal


type alias VimModel =
    { buffer : String
    , state : VState
    }


type VimMsg
    = StartCommand
    | ToBuffer String
