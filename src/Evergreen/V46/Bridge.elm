module Evergreen.V46.Bridge exposing (..)

import Dict
import Evergreen.V46.DimensionalModel
import Evergreen.V46.DuckDb


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V46.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V46.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V46.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V46.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V46.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V46.DimensionalModel.DimensionalModelRef Evergreen.V46.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V46.DimensionalModel.DimensionalModelRef Evergreen.V46.DuckDb.DuckDbRef Evergreen.V46.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V46.DimensionalModel.DimensionalModelRef Evergreen.V46.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V46.DimensionalModel.DimensionalModelRef Evergreen.V46.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V46.DimensionalModel.DimensionalModelRef Evergreen.V46.DuckDb.DuckDbRef (Evergreen.V46.DimensionalModel.KimballAssignment Evergreen.V46.DuckDb.DuckDbRef_ (List Evergreen.V46.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V46.DimensionalModel.DimensionalModelRef Evergreen.V46.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V46.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V46.DimensionalModel.DimensionalModelRef
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
