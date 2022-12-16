module Evergreen.V48.Bridge exposing (..)

import Dict
import Evergreen.V48.DimensionalModel
import Evergreen.V48.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V48.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V48.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V48.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V48.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V48.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V48.DimensionalModel.DimensionalModelRef Evergreen.V48.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V48.DimensionalModel.DimensionalModelRef Evergreen.V48.DuckDb.DuckDbRef Evergreen.V48.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V48.DimensionalModel.DimensionalModelRef Evergreen.V48.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V48.DimensionalModel.DimensionalModelRef Evergreen.V48.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V48.DimensionalModel.DimensionalModelRef Evergreen.V48.DuckDb.DuckDbRef (Evergreen.V48.DimensionalModel.KimballAssignment Evergreen.V48.DuckDb.DuckDbRef_ (List Evergreen.V48.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V48.DimensionalModel.DimensionalModelRef Evergreen.V48.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V48.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V48.DimensionalModel.DimensionalModelRef
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
