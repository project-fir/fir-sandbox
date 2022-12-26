module Evergreen.V61.Bridge exposing (..)

import Dict
import Evergreen.V61.DimensionalModel
import Evergreen.V61.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V61.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V61.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V61.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V61.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V61.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DuckDb.DuckDbRef Evergreen.V61.DimensionalModel.Position
    | AddDuckDbRefToModel Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DuckDb.DuckDbRef (Evergreen.V61.DimensionalModel.KimballAssignment Evergreen.V61.DuckDb.DuckDbRef_ (List Evergreen.V61.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V61.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V61.DimensionalModel.DimensionalModelRef
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
