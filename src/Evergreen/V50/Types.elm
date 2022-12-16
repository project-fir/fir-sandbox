module Evergreen.V50.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V50.Bridge
import Evergreen.V50.DimensionalModel
import Evergreen.V50.DuckDb
import Evergreen.V50.Gen.Pages
import Evergreen.V50.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V50.Shared.Model
    , page : Evergreen.V50.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V50.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V50.DimensionalModel.DimensionalModelRef Evergreen.V50.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V50.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V50.Shared.Msg
    | Page Evergreen.V50.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V50.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V50.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V50.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V50.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V50.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V50.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V50.Bridge.DeliveryEnvelope Evergreen.V50.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V50.Bridge.DeliveryEnvelope (List Evergreen.V50.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V50.DimensionalModel.DimensionalModelRef Evergreen.V50.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V50.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
