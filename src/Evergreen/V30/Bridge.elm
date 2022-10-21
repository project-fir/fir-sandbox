module Evergreen.V30.Bridge exposing (..)

import Dict
import Evergreen.V30.DimensionalModel
import Evergreen.V30.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V30.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V30.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V30.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V30.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V30.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V30.DimensionalModel.DimensionalModelRef Evergreen.V30.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V30.DimensionalModel.DimensionalModelRef Evergreen.V30.DuckDb.DuckDbRef Evergreen.V30.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V30.DimensionalModel.DimensionalModelRef Evergreen.V30.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V30.DimensionalModel.DimensionalModelRef Evergreen.V30.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V30.DimensionalModel.DimensionalModelRef Evergreen.V30.DuckDb.DuckDbRef (Evergreen.V30.DimensionalModel.KimballAssignment Evergreen.V30.DuckDb.DuckDbRef_ (List Evergreen.V30.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V30.DimensionalModel.DimensionalModelRef Evergreen.V30.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V30.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V30.DimensionalModel.DimensionalModelRef
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
