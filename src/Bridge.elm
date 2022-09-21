module Bridge exposing (..)

import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel DimensionalModelRef
    | FetchDimensionalModel DimensionalModelRef
    | UpdateDimensionalModel DimensionalModel
    | Admin_FetchAllBackendData
    | Admin_PingServer
    | Admin_RefreshDuckDbMetaData
    | Admin_PurgeBackendData
    | Kimball_FetchDuckDbRefs



-- NB: Naming conflicts with WebData, but this is for Lamdera data


type BackendErrorMessage
    = PlainMessage String


type DeliveryEnvelope data
    = BackendSuccess data
    | BackendError BackendErrorMessage


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage
