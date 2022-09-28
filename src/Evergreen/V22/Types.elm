module Evergreen.V22.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V22.Bridge
import Evergreen.V22.DimensionalModel
import Evergreen.V22.DuckDb
import Evergreen.V22.Gen.Pages
import Evergreen.V22.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V22.Shared.Model
    , page : Evergreen.V22.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V22.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V22.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V22.Shared.Msg
    | Page Evergreen.V22.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V22.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V22.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V22.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V22.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V22.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V22.Bridge.DeliveryEnvelope Evergreen.V22.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V22.Bridge.DeliveryEnvelope (List Evergreen.V22.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V22.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
