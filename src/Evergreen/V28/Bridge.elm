module Evergreen.V28.Bridge exposing (..)

import Dict
import Evergreen.V28.DimensionalModel
import Evergreen.V28.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V28.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V28.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V28.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V28.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V28.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V28.DimensionalModel.DimensionalModelRef Evergreen.V28.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V28.DimensionalModel.DimensionalModelRef Evergreen.V28.DuckDb.DuckDbRef Evergreen.V28.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V28.DimensionalModel.DimensionalModelRef Evergreen.V28.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V28.DimensionalModel.DimensionalModelRef Evergreen.V28.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V28.DimensionalModel.DimensionalModelRef Evergreen.V28.DuckDb.DuckDbRef (Evergreen.V28.DimensionalModel.KimballAssignment Evergreen.V28.DuckDb.DuckDbRef_ (List Evergreen.V28.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V28.DimensionalModel.DimensionalModelRef Evergreen.V28.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V28.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V28.DimensionalModel.DimensionalModelRef
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
