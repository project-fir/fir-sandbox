module Evergreen.V65.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V65.Bridge
import Evergreen.V65.DimensionalModel
import Evergreen.V65.FirApi
import Evergreen.V65.Gen.Pages
import Evergreen.V65.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V65.Shared.Model
    , page : Evergreen.V65.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V65.FirApi.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V65.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V65.Shared.Msg
    | Page Evergreen.V65.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V65.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V65.FirApi.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V65.FirApi.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V65.FirApi.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V65.FirApi.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V65.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V65.Bridge.DeliveryEnvelope Evergreen.V65.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V65.Bridge.DeliveryEnvelope (List Evergreen.V65.FirApi.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V65.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
