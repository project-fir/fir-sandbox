module Evergreen.V16.Bridge exposing (..)

import Evergreen.V16.DimensionalModel


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V16.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V16.DimensionalModel.DimensionalModelRef
    | UpdateDimensionalModel Evergreen.V16.DimensionalModel.DimensionalModel
