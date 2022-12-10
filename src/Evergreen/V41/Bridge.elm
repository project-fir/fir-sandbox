module Evergreen.V41.Bridge exposing (..)

import Dict
import Evergreen.V41.DimensionalModel
import Evergreen.V41.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V41.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V41.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V41.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V41.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V41.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V41.DimensionalModel.DimensionalModelRef Evergreen.V41.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V41.DimensionalModel.DimensionalModelRef Evergreen.V41.DuckDb.DuckDbRef Evergreen.V41.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V41.DimensionalModel.DimensionalModelRef Evergreen.V41.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V41.DimensionalModel.DimensionalModelRef Evergreen.V41.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V41.DimensionalModel.DimensionalModelRef Evergreen.V41.DuckDb.DuckDbRef (Evergreen.V41.DimensionalModel.KimballAssignment Evergreen.V41.DuckDb.DuckDbRef_ (List Evergreen.V41.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V41.DimensionalModel.DimensionalModelRef Evergreen.V41.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V41.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V41.DimensionalModel.DimensionalModelRef
    | UpdateDimensionalModel DimensionalModelUpdate
    | Admin_FetchAllBackendData
    | Admin_PingServer
    | Admin_Task_BuildDateDimTable String String
    | Admin_InitiateDuckDbCacheWarmingCycle
    | Admin_PurgeBackendData
    | Kimball_FetchDuckDbRefs


type DeliveryEnvelope data
    = BackendSuccess data
    | BackendError BackendErrorMessage
