module Evergreen.V56.Bridge exposing (..)

import Dict
import Evergreen.V56.DimensionalModel
import Evergreen.V56.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V56.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V56.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V56.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V56.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V56.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DuckDb.DuckDbRef Evergreen.V56.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DuckDb.DuckDbRef (Evergreen.V56.DimensionalModel.KimballAssignment Evergreen.V56.DuckDb.DuckDbRef_ (List Evergreen.V56.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V56.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V56.DimensionalModel.DimensionalModelRef
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
