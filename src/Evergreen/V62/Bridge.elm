module Evergreen.V62.Bridge exposing (..)

import Dict
import Evergreen.V62.DimensionalModel
import Evergreen.V62.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V62.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V62.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V62.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V62.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V62.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DuckDb.DuckDbRef Evergreen.V62.DimensionalModel.Position
    | AddDuckDbRefToModel Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DuckDb.DuckDbRef (Evergreen.V62.DimensionalModel.KimballAssignment Evergreen.V62.DuckDb.DuckDbRef_ (List Evergreen.V62.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V62.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V62.DimensionalModel.DimensionalModelRef
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
