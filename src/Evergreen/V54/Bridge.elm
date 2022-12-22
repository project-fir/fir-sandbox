module Evergreen.V54.Bridge exposing (..)

import Dict
import Evergreen.V54.DimensionalModel
import Evergreen.V54.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V54.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V54.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V54.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V54.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V54.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V54.DimensionalModel.DimensionalModelRef Evergreen.V54.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V54.DimensionalModel.DimensionalModelRef Evergreen.V54.DuckDb.DuckDbRef Evergreen.V54.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V54.DimensionalModel.DimensionalModelRef Evergreen.V54.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V54.DimensionalModel.DimensionalModelRef Evergreen.V54.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V54.DimensionalModel.DimensionalModelRef Evergreen.V54.DuckDb.DuckDbRef (Evergreen.V54.DimensionalModel.KimballAssignment Evergreen.V54.DuckDb.DuckDbRef_ (List Evergreen.V54.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V54.DimensionalModel.DimensionalModelRef Evergreen.V54.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V54.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V54.DimensionalModel.DimensionalModelRef
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
