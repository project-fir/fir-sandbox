module Evergreen.V54.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V54.Bridge
import Evergreen.V54.DimensionalModel
import Evergreen.V54.DuckDb
import Evergreen.V54.Gen.Pages
import Evergreen.V54.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V54.Shared.Model
    , page : Evergreen.V54.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V54.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V54.DimensionalModel.DimensionalModelRef Evergreen.V54.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V54.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V54.Shared.Msg
    | Page Evergreen.V54.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V54.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V54.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V54.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V54.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V54.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V54.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V54.Bridge.DeliveryEnvelope Evergreen.V54.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V54.Bridge.DeliveryEnvelope (List Evergreen.V54.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V54.DimensionalModel.DimensionalModelRef Evergreen.V54.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V54.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
