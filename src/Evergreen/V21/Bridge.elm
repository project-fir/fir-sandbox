module Evergreen.V21.Bridge exposing (..)

import Dict
import Evergreen.V21.DimensionalModel
import Evergreen.V21.DuckDb
import Graph


type alias DuckDbMetaDataCacheEntry =
    { ref : Evergreen.V21.DuckDb.DuckDbRef
    , columnDescriptions : List Evergreen.V21.DuckDb.DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List Evergreen.V21.DuckDb.DuckDbRef
    , metaData : Dict.Dict Evergreen.V21.DuckDb.DuckDbRefString DuckDbMetaDataCacheEntry
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List Evergreen.V21.DuckDb.DuckDbRef)
    | Hot DuckDbCache


type alias BackendErrorMessage =
    String


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type DimensionalModelUpdate
    = FullReplacement Evergreen.V21.DimensionalModel.DimensionalModelRef Evergreen.V21.DimensionalModel.DimensionalModel
    | UpdateNodePosition Evergreen.V21.DimensionalModel.DimensionalModelRef Evergreen.V21.DuckDb.DuckDbRef Evergreen.V21.DimensionalModel.PositionPx
    | AddDuckDbRefToModel Evergreen.V21.DimensionalModel.DimensionalModelRef Evergreen.V21.DuckDb.DuckDbRef
    | ToggleIncludedNode Evergreen.V21.DimensionalModel.DimensionalModelRef Evergreen.V21.DuckDb.DuckDbRef
    | UpdateAssignment Evergreen.V21.DimensionalModel.DimensionalModelRef Evergreen.V21.DuckDb.DuckDbRef (Evergreen.V21.DimensionalModel.KimballAssignment Evergreen.V21.DuckDb.DuckDbRef_ (List Evergreen.V21.DuckDb.DuckDbColumnDescription))
    | UpdateGraph Evergreen.V21.DimensionalModel.DimensionalModelRef (Graph.Graph Evergreen.V21.DuckDb.DuckDbRef_ Evergreen.V21.DimensionalModel.DimensionalModelEdge)


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel Evergreen.V21.DimensionalModel.DimensionalModelRef
    | FetchDimensionalModel Evergreen.V21.DimensionalModel.DimensionalModelRef
    | UpdateDimensionalModel DimensionalModelUpdate
    | Admin_FetchAllBackendData
    | Admin_PingServer
    | Admin_InitiateDuckDbCacheWarmingCycle
    | Admin_PurgeBackendData
    | Kimball_FetchDuckDbRefs


type DeliveryEnvelope data
    = BackendSuccess data
    | BackendError BackendErrorMessage
