module Evergreen.V64.Bridge exposing (..)

import Dict
import Evergreen.V64.DimensionalModel
import Evergreen.V64.FirApi


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V64.FirApi.DuckDbRef
    , columnDescriptions : List Evergreen.V64.FirApi.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V64.FirApi.DuckDbRef
    , metaData : Dict.Dict Evergreen.V64.FirApi.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V64.FirApi.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.FirApi.DuckDbRef Evergreen.V64.DimensionalModel.Position
    | AddDuckDbRefToModel Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.FirApi.DuckDbRef
    | ToggleIncludedNode Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.FirApi.DuckDbRef
    | UpdateAssignment Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.FirApi.DuckDbRef (Evergreen.V64.DimensionalModel.KimballAssignment Evergreen.V64.FirApi.DuckDbRef_ (List Evergreen.V64.FirApi.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V64.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V64.DimensionalModel.DimensionalModelRef
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
