module Bridge exposing (..)

import Dict exposing (Dict)
import DimensionalModel exposing (ColumnGraph, DimensionalModel, DimensionalModelRef, KimballAssignment, Position)
import DuckDb exposing (DuckDbColumnDescription, DuckDbRef, DuckDbRefString, DuckDbRef_)


type ToBackend
    = FetchDimensionalModelRefs
    | CreateNewDimensionalModel DimensionalModelRef
    | FetchDimensionalModel DimensionalModelRef
    | UpdateDimensionalModel DimensionalModelUpdate
    | Admin_FetchAllBackendData
    | Admin_PingServer
    | Admin_Task_BuildDateDimTable String String
    | Admin_InitiateDuckDbCacheWarmingCycle
    | Admin_PurgeBackendData
    | Kimball_FetchDuckDbRefs


type DimensionalModelUpdate
    = FullReplacement DimensionalModelRef DimensionalModel
    | UpdateNodePosition DimensionalModelRef DuckDbRef Position
    | AddDuckDbRefToModel DimensionalModelRef DuckDbRef
    | ToggleIncludedNode DimensionalModelRef DuckDbRef
    | UpdateAssignment DimensionalModelRef DuckDbRef (KimballAssignment DuckDbRef_ (List DuckDbColumnDescription))
    | UpdateGraph DimensionalModelRef ColumnGraph



-- NB: Naming conflicts with WebData, but this is for Lamdera data


type alias BackendErrorMessage =
    String


type DeliveryEnvelope data
    = BackendSuccess data
    | BackendError BackendErrorMessage


type BackendData data
    = NotAsked_
    | Fetching_
    | Success_ data
    | Error_ BackendErrorMessage


type alias DuckDbMetaDataCacheEntry =
    { ref : DuckDbRef
    , columnDescriptions : List DuckDbColumnDescription
    }


type DuckDbCache_
    = Cold DuckDbCache
    | WarmingCycleInitiated DuckDbCache
    | Warming DuckDbCache DuckDbCache (List DuckDbRef)
    | Hot DuckDbCache


type alias DuckDbCache =
    { refs : List DuckDbRef
    , metaData : Dict DuckDbRefString DuckDbMetaDataCacheEntry
    }


defaultColdCache : DuckDbCache
defaultColdCache =
    { refs = []
    , metaData = Dict.empty
    }
