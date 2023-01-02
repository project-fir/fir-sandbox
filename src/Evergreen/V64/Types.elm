module Evergreen.V64.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V64.Bridge
import Evergreen.V64.DimensionalModel
import Evergreen.V64.FirApi
import Evergreen.V64.Gen.Pages
import Evergreen.V64.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V64.Shared.Model
    , page : Evergreen.V64.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V64.FirApi.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V64.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V64.Shared.Msg
    | Page Evergreen.V64.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V64.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V64.FirApi.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V64.FirApi.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V64.FirApi.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V64.FirApi.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V64.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V64.Bridge.DeliveryEnvelope Evergreen.V64.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V64.Bridge.DeliveryEnvelope (List Evergreen.V64.FirApi.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V64.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
