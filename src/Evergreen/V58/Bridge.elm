module Evergreen.V58.Bridge exposing (..)

import Dict
import Evergreen.V58.DimensionalModel
import Evergreen.V58.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V58.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V58.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V58.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V58.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V58.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DuckDb.DuckDbRef Evergreen.V58.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DuckDb.DuckDbRef (Evergreen.V58.DimensionalModel.KimballAssignment Evergreen.V58.DuckDb.DuckDbRef_ (List Evergreen.V58.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V58.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V58.DimensionalModel.DimensionalModelRef
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
