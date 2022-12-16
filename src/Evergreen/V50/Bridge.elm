module Evergreen.V50.Bridge exposing (..)

import Dict
import Evergreen.V50.DimensionalModel
import Evergreen.V50.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V50.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V50.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V50.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V50.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V50.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V50.DimensionalModel.DimensionalModelRef Evergreen.V50.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V50.DimensionalModel.DimensionalModelRef Evergreen.V50.DuckDb.DuckDbRef Evergreen.V50.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V50.DimensionalModel.DimensionalModelRef Evergreen.V50.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V50.DimensionalModel.DimensionalModelRef Evergreen.V50.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V50.DimensionalModel.DimensionalModelRef Evergreen.V50.DuckDb.DuckDbRef (Evergreen.V50.DimensionalModel.KimballAssignment Evergreen.V50.DuckDb.DuckDbRef_ (List Evergreen.V50.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V50.DimensionalModel.DimensionalModelRef Evergreen.V50.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V50.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V50.DimensionalModel.DimensionalModelRef
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
