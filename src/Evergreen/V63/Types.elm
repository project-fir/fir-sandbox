module Evergreen.V63.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V63.Bridge
import Evergreen.V63.DimensionalModel
import Evergreen.V63.FirApi
import Evergreen.V63.Gen.Pages
import Evergreen.V63.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V63.Shared.Model
    , page : Evergreen.V63.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V63.FirApi.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V63.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V63.Shared.Msg
    | Page Evergreen.V63.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V63.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V63.FirApi.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V63.FirApi.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V63.FirApi.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V63.FirApi.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V63.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V63.Bridge.DeliveryEnvelope Evergreen.V63.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V63.Bridge.DeliveryEnvelope (List Evergreen.V63.FirApi.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V63.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
