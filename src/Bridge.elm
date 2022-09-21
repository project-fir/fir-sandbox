module Bridge exposing (..)

import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel DimensionalModelRef
    | FetchDimensionalModel DimensionalModelRef
    | UpdateDimensionalModel DimensionalModel
    | Admin_FetchAllBackendData



-- NB: Naming conflicts with WebData, but this is for Lamdera data


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_
