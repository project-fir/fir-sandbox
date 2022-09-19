module Bridge exposing (..)

import DimensionalModel exposing (DimensionalModelRef)


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel DimensionalModelRef



-- NB: Naming conflicts with WebData, but this is for Lamdera data


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_
