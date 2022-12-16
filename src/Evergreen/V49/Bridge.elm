module Evergreen.V49.Bridge exposing (..)

import Dict
import Evergreen.V49.DimensionalModel
import Evergreen.V49.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V49.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V49.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V49.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V49.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V49.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V49.DimensionalModel.DimensionalModelRef Evergreen.V49.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V49.DimensionalModel.DimensionalModelRef Evergreen.V49.DuckDb.DuckDbRef Evergreen.V49.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V49.DimensionalModel.DimensionalModelRef Evergreen.V49.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V49.DimensionalModel.DimensionalModelRef Evergreen.V49.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V49.DimensionalModel.DimensionalModelRef Evergreen.V49.DuckDb.DuckDbRef (Evergreen.V49.DimensionalModel.KimballAssignment Evergreen.V49.DuckDb.DuckDbRef_ (List Evergreen.V49.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V49.DimensionalModel.DimensionalModelRef Evergreen.V49.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V49.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V49.DimensionalModel.DimensionalModelRef
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
