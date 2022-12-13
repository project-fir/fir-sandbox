module Evergreen.V45.Bridge exposing (..)

import Dict
import Evergreen.V45.DimensionalModel
import Evergreen.V45.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V45.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V45.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V45.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V45.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V45.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V45.DimensionalModel.DimensionalModelRef Evergreen.V45.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V45.DimensionalModel.DimensionalModelRef Evergreen.V45.DuckDb.DuckDbRef Evergreen.V45.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V45.DimensionalModel.DimensionalModelRef Evergreen.V45.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V45.DimensionalModel.DimensionalModelRef Evergreen.V45.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V45.DimensionalModel.DimensionalModelRef Evergreen.V45.DuckDb.DuckDbRef (Evergreen.V45.DimensionalModel.KimballAssignment Evergreen.V45.DuckDb.DuckDbRef_ (List Evergreen.V45.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V45.DimensionalModel.DimensionalModelRef Evergreen.V45.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V45.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V45.DimensionalModel.DimensionalModelRef
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
