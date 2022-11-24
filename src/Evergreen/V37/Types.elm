module Evergreen.V37.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V37.Bridge
import Evergreen.V37.DimensionalModel
import Evergreen.V37.DuckDb
import Evergreen.V37.Gen.Pages
import Evergreen.V37.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V37.Shared.Model
    , page : Evergreen.V37.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V37.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V37.DimensionalModel.DimensionalModelRef Evergreen.V37.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V37.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V37.Shared.Msg
    | Page Evergreen.V37.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V37.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V37.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V37.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V37.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V37.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V37.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V37.Bridge.DeliveryEnvelope Evergreen.V37.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V37.Bridge.DeliveryEnvelope (List Evergreen.V37.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V37.DimensionalModel.DimensionalModelRef Evergreen.V37.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V37.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
