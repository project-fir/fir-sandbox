module Evergreen.V43.Bridge exposing (..)

import Dict
import Evergreen.V43.DimensionalModel
import Evergreen.V43.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V43.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V43.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V43.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V43.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V43.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V43.DimensionalModel.DimensionalModelRef Evergreen.V43.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V43.DimensionalModel.DimensionalModelRef Evergreen.V43.DuckDb.DuckDbRef Evergreen.V43.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V43.DimensionalModel.DimensionalModelRef Evergreen.V43.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V43.DimensionalModel.DimensionalModelRef Evergreen.V43.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V43.DimensionalModel.DimensionalModelRef Evergreen.V43.DuckDb.DuckDbRef (Evergreen.V43.DimensionalModel.KimballAssignment Evergreen.V43.DuckDb.DuckDbRef_ (List Evergreen.V43.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V43.DimensionalModel.DimensionalModelRef Evergreen.V43.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V43.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V43.DimensionalModel.DimensionalModelRef
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
