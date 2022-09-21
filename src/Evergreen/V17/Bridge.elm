module Evergreen.V17.Bridge exposing (..)

import Evergreen.V17.DimensionalModel


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V17.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V17.DimensionalModel.DimensionalModelRef
    | UpdateDimensionalModel Evergreen.V17.DimensionalModel.DimensionalModel
    | Admin_FetchAllBackendData
    | Admin_PingServer
