module Evergreen.V22.Bridge exposing (..)

import Dict
import Evergreen.V22.DimensionalModel
import Evergreen.V22.DuckDb
import Graph


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V22.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V22.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V22.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V22.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V22.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DuckDb.DuckDbRef Evergreen.V22.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DuckDb.DuckDbRef (Evergreen.V22.DimensionalModel.KimballAssignment Evergreen.V22.DuckDb.DuckDbRef_ (List Evergreen.V22.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V22.DimensionalModel.DimensionalModelRef (Graph.Graph Evergreen.V22.DuckDb.DuckDbRef_ Evergreen.V22.DimensionalModel.DimensionalModelEdge)


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V22.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V22.DimensionalModel.DimensionalModelRef
    | UpdateDimensionalModel DimensionalModelUpdate
    | Admin_FetchAllBackendData
    | Admin_PingServer
    | Admin_InitiateDuckDbCacheWarmingCycle
    | Admin_PurgeBackendData
    | Kimball_FetchDuckDbRefs


type DeliveryEnvelope data
    = BackendSuccess data
    | BackendError BackendErrorMessage
