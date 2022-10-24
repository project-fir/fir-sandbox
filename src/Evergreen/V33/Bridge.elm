module Evergreen.V33.Bridge exposing (..)

import Dict
import Evergreen.V33.DimensionalModel
import Evergreen.V33.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V33.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V33.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V33.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V33.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V33.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V33.DimensionalModel.DimensionalModelRef Evergreen.V33.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V33.DimensionalModel.DimensionalModelRef Evergreen.V33.DuckDb.DuckDbRef Evergreen.V33.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V33.DimensionalModel.DimensionalModelRef Evergreen.V33.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V33.DimensionalModel.DimensionalModelRef Evergreen.V33.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V33.DimensionalModel.DimensionalModelRef Evergreen.V33.DuckDb.DuckDbRef (Evergreen.V33.DimensionalModel.KimballAssignment Evergreen.V33.DuckDb.DuckDbRef_ (List Evergreen.V33.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V33.DimensionalModel.DimensionalModelRef Evergreen.V33.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V33.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V33.DimensionalModel.DimensionalModelRef
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
