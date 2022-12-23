module Evergreen.V58.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V58.Bridge
import Evergreen.V58.DimensionalModel
import Evergreen.V58.DuckDb
import Evergreen.V58.Gen.Pages
import Evergreen.V58.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V58.Shared.Model
    , page : Evergreen.V58.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V58.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V58.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V58.Shared.Msg
    | Page Evergreen.V58.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V58.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V58.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V58.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V58.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V58.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V58.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V58.Bridge.DeliveryEnvelope Evergreen.V58.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V58.Bridge.DeliveryEnvelope (List Evergreen.V58.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V58.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
