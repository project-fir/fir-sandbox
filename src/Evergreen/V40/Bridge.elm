module Evergreen.V40.Bridge exposing (..)

import Dict
import Evergreen.V40.DimensionalModel
import Evergreen.V40.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V40.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V40.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V40.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V40.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V40.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V40.DimensionalModel.DimensionalModelRef Evergreen.V40.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V40.DimensionalModel.DimensionalModelRef Evergreen.V40.DuckDb.DuckDbRef Evergreen.V40.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V40.DimensionalModel.DimensionalModelRef Evergreen.V40.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V40.DimensionalModel.DimensionalModelRef Evergreen.V40.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V40.DimensionalModel.DimensionalModelRef Evergreen.V40.DuckDb.DuckDbRef (Evergreen.V40.DimensionalModel.KimballAssignment Evergreen.V40.DuckDb.DuckDbRef_ (List Evergreen.V40.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V40.DimensionalModel.DimensionalModelRef Evergreen.V40.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V40.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V40.DimensionalModel.DimensionalModelRef
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
