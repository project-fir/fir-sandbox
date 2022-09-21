module Bridge exposing (..)

import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)
import DuckDb exposing (DuckDbColumnDescription, DuckDbRef, DuckDbRefString)


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


type alias DuckDbMetaDataCacheEntry =
    { ref : DuckDbRef
    , columnDescriptions : List DuckDbColumnDescription
    }


type DuckDbCache_
    = Cold
    | WarmingCycleInitiated (Maybe DuckDbCache)
    | Warming (Maybe DuckDbCache) (Maybe DuckDbCache) (List DuckDbRef)
    | Hot (Maybe DuckDbCache)


type alias DuckDbCache =
    { refs : List DuckDbRef
    , metaData : Dict DuckDbRefString DuckDbMetaDataCacheEntry
    }
