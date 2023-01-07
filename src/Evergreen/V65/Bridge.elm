module Evergreen.V65.Bridge exposing (..)

import Dict
import Evergreen.V65.DimensionalModel
import Evergreen.V65.FirApi


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V65.FirApi.DuckDbRef
    , columnDescriptions : List Evergreen.V65.FirApi.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V65.FirApi.DuckDbRef
    , metaData : Dict.Dict Evergreen.V65.FirApi.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V65.FirApi.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.FirApi.DuckDbRef Evergreen.V65.DimensionalModel.Position
    | AddDuckDbRefToModel Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.FirApi.DuckDbRef
    | ToggleIncludedNode Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.FirApi.DuckDbRef
    | UpdateAssignment Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.FirApi.DuckDbRef (Evergreen.V65.DimensionalModel.KimballAssignment Evergreen.V65.FirApi.DuckDbRef_ (List Evergreen.V65.FirApi.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V65.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V65.DimensionalModel.DimensionalModelRef
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
