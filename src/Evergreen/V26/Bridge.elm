module Evergreen.V26.Bridge exposing (..)

import Dict
import Evergreen.V26.DimensionalModel
import Evergreen.V26.DuckDb
import Graph


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V26.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V26.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V26.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V26.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V26.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DuckDb.DuckDbRef Evergreen.V26.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DuckDb.DuckDbRef (Evergreen.V26.DimensionalModel.KimballAssignment Evergreen.V26.DuckDb.DuckDbRef_ (List Evergreen.V26.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V26.DimensionalModel.DimensionalModelRef (Graph.Graph Evergreen.V26.DuckDb.DuckDbRef_ Evergreen.V26.DimensionalModel.DimensionalModelEdge)


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V26.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V26.DimensionalModel.DimensionalModelRef
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
