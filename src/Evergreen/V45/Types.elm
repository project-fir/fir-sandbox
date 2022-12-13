module Evergreen.V45.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V45.Bridge
import Evergreen.V45.DimensionalModel
import Evergreen.V45.DuckDb
import Evergreen.V45.Gen.Pages
import Evergreen.V45.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V45.Shared.Model
    , page : Evergreen.V45.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V45.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V45.DimensionalModel.DimensionalModelRef Evergreen.V45.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V45.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V45.Shared.Msg
    | Page Evergreen.V45.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V45.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V45.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V45.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V45.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V45.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V45.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V45.Bridge.DeliveryEnvelope Evergreen.V45.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V45.Bridge.DeliveryEnvelope (List Evergreen.V45.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V45.DimensionalModel.DimensionalModelRef Evergreen.V45.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V45.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
