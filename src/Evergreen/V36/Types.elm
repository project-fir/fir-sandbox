module Evergreen.V36.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V36.Bridge
import Evergreen.V36.DimensionalModel
import Evergreen.V36.DuckDb
import Evergreen.V36.Gen.Pages
import Evergreen.V36.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V36.Shared.Model
    , page : Evergreen.V36.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V36.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V36.DimensionalModel.DimensionalModelRef Evergreen.V36.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V36.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V36.Shared.Msg
    | Page Evergreen.V36.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V36.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V36.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V36.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V36.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V36.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V36.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V36.Bridge.DeliveryEnvelope Evergreen.V36.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V36.Bridge.DeliveryEnvelope (List Evergreen.V36.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V36.DimensionalModel.DimensionalModelRef Evergreen.V36.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V36.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
