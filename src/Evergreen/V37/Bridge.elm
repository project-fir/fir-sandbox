module Evergreen.V37.Bridge exposing (..)

import Dict
import Evergreen.V37.DimensionalModel
import Evergreen.V37.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V37.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V37.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V37.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V37.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V37.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V37.DimensionalModel.DimensionalModelRef Evergreen.V37.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V37.DimensionalModel.DimensionalModelRef Evergreen.V37.DuckDb.DuckDbRef Evergreen.V37.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V37.DimensionalModel.DimensionalModelRef Evergreen.V37.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V37.DimensionalModel.DimensionalModelRef Evergreen.V37.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V37.DimensionalModel.DimensionalModelRef Evergreen.V37.DuckDb.DuckDbRef (Evergreen.V37.DimensionalModel.KimballAssignment Evergreen.V37.DuckDb.DuckDbRef_ (List Evergreen.V37.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V37.DimensionalModel.DimensionalModelRef Evergreen.V37.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V37.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V37.DimensionalModel.DimensionalModelRef
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
