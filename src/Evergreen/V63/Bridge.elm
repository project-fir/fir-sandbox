module Evergreen.V63.Bridge exposing (..)

import Dict
import Evergreen.V63.DimensionalModel
import Evergreen.V63.FirApi


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V63.FirApi.DuckDbRef
    , columnDescriptions : List Evergreen.V63.FirApi.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V63.FirApi.DuckDbRef
    , metaData : Dict.Dict Evergreen.V63.FirApi.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V63.FirApi.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.FirApi.DuckDbRef Evergreen.V63.DimensionalModel.Position
    | AddDuckDbRefToModel Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.FirApi.DuckDbRef
    | ToggleIncludedNode Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.FirApi.DuckDbRef
    | UpdateAssignment Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.FirApi.DuckDbRef (Evergreen.V63.DimensionalModel.KimballAssignment Evergreen.V63.FirApi.DuckDbRef_ (List Evergreen.V63.FirApi.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.DimensionalModel.ColumnGraph


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V63.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V63.DimensionalModel.DimensionalModelRef
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
