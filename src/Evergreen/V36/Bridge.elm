module Evergreen.V36.Bridge exposing (..)

import Dict
import Evergreen.V36.DimensionalModel
import Evergreen.V36.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V36.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V36.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V36.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V36.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V36.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V36.DimensionalModel.DimensionalModelRef Evergreen.V36.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V36.DimensionalModel.DimensionalModelRef Evergreen.V36.DuckDb.DuckDbRef Evergreen.V36.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V36.DimensionalModel.DimensionalModelRef Evergreen.V36.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V36.DimensionalModel.DimensionalModelRef Evergreen.V36.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V36.DimensionalModel.DimensionalModelRef Evergreen.V36.DuckDb.DuckDbRef (Evergreen.V36.DimensionalModel.KimballAssignment Evergreen.V36.DuckDb.DuckDbRef_ (List Evergreen.V36.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V36.DimensionalModel.DimensionalModelRef Evergreen.V36.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V36.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V36.DimensionalModel.DimensionalModelRef
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
