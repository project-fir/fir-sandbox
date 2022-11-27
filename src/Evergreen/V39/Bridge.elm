module Evergreen.V39.Bridge exposing (..)

import Dict
import Evergreen.V39.DimensionalModel
import Evergreen.V39.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V39.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V39.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V39.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V39.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V39.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V39.DimensionalModel.DimensionalModelRef Evergreen.V39.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V39.DimensionalModel.DimensionalModelRef Evergreen.V39.DuckDb.DuckDbRef Evergreen.V39.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V39.DimensionalModel.DimensionalModelRef Evergreen.V39.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V39.DimensionalModel.DimensionalModelRef Evergreen.V39.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V39.DimensionalModel.DimensionalModelRef Evergreen.V39.DuckDb.DuckDbRef (Evergreen.V39.DimensionalModel.KimballAssignment Evergreen.V39.DuckDb.DuckDbRef_ (List Evergreen.V39.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V39.DimensionalModel.DimensionalModelRef Evergreen.V39.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V39.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V39.DimensionalModel.DimensionalModelRef
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
