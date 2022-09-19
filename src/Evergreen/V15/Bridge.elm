module Evergreen.V15.Bridge exposing (..)

import Evergreen.V15.DimensionalModel


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V15.DimensionalModel.DimensionalModelRef
