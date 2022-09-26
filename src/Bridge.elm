module Bridge exposing (..)

import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)
import DuckDb exposing (DuckDbColumnDescription, DuckDbRef, DuckDbRefString)


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel DimensionalModelRef
    | FetchDimensionalModel DimensionalModelRef
    | FetchDuckDbMetaData DuckDbRef
    | UpdateDimensionalModel DuckDbRef DimensionalModel
    | Admin_FetchAllBackendData
    | Admin_PingServer
    | Admin_InitiateDuckDbCacheWarmingCycle
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


type alias DuckDbMetaDataCacheEntry =
    { ref : DuckDbRef
    , columnDescriptions : List DuckDbColumnDescription
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List DuckDbRef)
    | Hot DuckDbCache


type alias DuckDbCache =
    { refs : List DuckDbRef
    , metaData : Dict DuckDbRefString DuckDbMetaDataCacheEntry
    }


defaultColdCache : DuckDbCache
defaultColdCache =
    { refs = []
    , metaData = Dict.empty
    }
