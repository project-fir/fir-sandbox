module Evergreen.V41.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V41.Bridge
import Evergreen.V41.DimensionalModel
import Evergreen.V41.DuckDb
import Evergreen.V41.Gen.Pages
import Evergreen.V41.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V41.Shared.Model
    , page : Evergreen.V41.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V41.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V41.DimensionalModel.DimensionalModelRef Evergreen.V41.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V41.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V41.Shared.Msg
    | Page Evergreen.V41.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V41.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V41.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V41.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V41.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V41.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V41.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V41.Bridge.DeliveryEnvelope Evergreen.V41.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V41.Bridge.DeliveryEnvelope (List Evergreen.V41.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V41.DimensionalModel.DimensionalModelRef Evergreen.V41.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V41.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
