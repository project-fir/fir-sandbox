module Evergreen.V21.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V21.Bridge
import Evergreen.V21.DimensionalModel
import Evergreen.V21.DuckDb
import Evergreen.V21.Gen.Pages
import Evergreen.V21.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V21.Shared.Model
    , page : Evergreen.V21.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V21.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V21.DimensionalModel.DimensionalModelRef Evergreen.V21.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V21.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V21.Shared.Msg
    | Page Evergreen.V21.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V21.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V21.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V21.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V21.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V21.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V21.Bridge.DeliveryEnvelope Evergreen.V21.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V21.Bridge.DeliveryEnvelope (List Evergreen.V21.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V21.DimensionalModel.DimensionalModelRef Evergreen.V21.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V21.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
