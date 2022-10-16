module Evergreen.V29.Bridge exposing (..)

import Dict
import Evergreen.V29.DimensionalModel
import Evergreen.V29.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V29.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V29.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V29.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V29.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V29.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V29.DimensionalModel.DimensionalModelRef Evergreen.V29.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V29.DimensionalModel.DimensionalModelRef Evergreen.V29.DuckDb.DuckDbRef Evergreen.V29.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V29.DimensionalModel.DimensionalModelRef Evergreen.V29.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V29.DimensionalModel.DimensionalModelRef Evergreen.V29.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V29.DimensionalModel.DimensionalModelRef Evergreen.V29.DuckDb.DuckDbRef (Evergreen.V29.DimensionalModel.KimballAssignment Evergreen.V29.DuckDb.DuckDbRef_ (List Evergreen.V29.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V29.DimensionalModel.DimensionalModelRef Evergreen.V29.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V29.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V29.DimensionalModel.DimensionalModelRef
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
