module Evergreen.V38.Bridge exposing (..)

import Dict
import Evergreen.V38.DimensionalModel
import Evergreen.V38.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V38.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V38.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V38.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V38.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V38.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DuckDb.DuckDbRef Evergreen.V38.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DuckDb.DuckDbRef (Evergreen.V38.DimensionalModel.KimballAssignment Evergreen.V38.DuckDb.DuckDbRef_ (List Evergreen.V38.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V38.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V38.DimensionalModel.DimensionalModelRef
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
