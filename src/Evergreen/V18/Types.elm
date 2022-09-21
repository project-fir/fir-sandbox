module Evergreen.V18.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V18.Bridge
import Evergreen.V18.DimensionalModel
import Evergreen.V18.DuckDb
import Evergreen.V18.Gen.Pages
import Evergreen.V18.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V18.Shared.Model
    , page : Evergreen.V18.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V18.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V18.DimensionalModel.DimensionalModelRef Evergreen.V18.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V18.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V18.Shared.Msg
    | Page Evergreen.V18.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V18.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V18.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V18.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V18.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V18.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel Evergreen.V18.DimensionalModel.DimensionalModel
    | DeliverDuckDbRefs (Evergreen.V18.Bridge.DeliveryEnvelope (List Evergreen.V18.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V18.DimensionalModel.DimensionalModelRef Evergreen.V18.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V18.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
