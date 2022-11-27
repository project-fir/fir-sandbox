module Evergreen.V39.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V39.Bridge
import Evergreen.V39.DimensionalModel
import Evergreen.V39.DuckDb
import Evergreen.V39.Gen.Pages
import Evergreen.V39.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V39.Shared.Model
    , page : Evergreen.V39.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V39.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V39.DimensionalModel.DimensionalModelRef Evergreen.V39.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V39.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V39.Shared.Msg
    | Page Evergreen.V39.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V39.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V39.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V39.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V39.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V39.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V39.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V39.Bridge.DeliveryEnvelope Evergreen.V39.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V39.Bridge.DeliveryEnvelope (List Evergreen.V39.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V39.DimensionalModel.DimensionalModelRef Evergreen.V39.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V39.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
