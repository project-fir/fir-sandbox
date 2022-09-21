module Evergreen.V18.Bridge exposing (..)

import Dict
import Evergreen.V18.DimensionalModel
import Evergreen.V18.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V18.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V18.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V18.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V18.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V18.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type BackendErrorMessage
    = PlainMessage String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V18.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V18.DimensionalModel.DimensionalModelRef
    | UpdateDimensionalModel Evergreen.V18.DimensionalModel.DimensionalModel
    | Admin_FetchAllBackendData
    | Admin_PingServer
    | Admin_InitiateDuckDbCacheWarmingCycle
    | Admin_PurgeBackendData
    | Kimball_FetchDuckDbRefs


type DeliveryEnvelope data
    = BackendSuccess data
    | BackendError BackendErrorMessage
