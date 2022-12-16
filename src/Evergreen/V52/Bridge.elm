module Evergreen.V52.Bridge exposing (..)

import Dict
import Evergreen.V52.DimensionalModel
import Evergreen.V52.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V52.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V52.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V52.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V52.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V52.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V52.DimensionalModel.DimensionalModelRef Evergreen.V52.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V52.DimensionalModel.DimensionalModelRef Evergreen.V52.DuckDb.DuckDbRef Evergreen.V52.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V52.DimensionalModel.DimensionalModelRef Evergreen.V52.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V52.DimensionalModel.DimensionalModelRef Evergreen.V52.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V52.DimensionalModel.DimensionalModelRef Evergreen.V52.DuckDb.DuckDbRef (Evergreen.V52.DimensionalModel.KimballAssignment Evergreen.V52.DuckDb.DuckDbRef_ (List Evergreen.V52.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V52.DimensionalModel.DimensionalModelRef Evergreen.V52.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V52.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V52.DimensionalModel.DimensionalModelRef
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
