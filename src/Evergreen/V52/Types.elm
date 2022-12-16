module Evergreen.V52.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V52.Bridge
import Evergreen.V52.DimensionalModel
import Evergreen.V52.DuckDb
import Evergreen.V52.Gen.Pages
import Evergreen.V52.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V52.Shared.Model
    , page : Evergreen.V52.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V52.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V52.DimensionalModel.DimensionalModelRef Evergreen.V52.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V52.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V52.Shared.Msg
    | Page Evergreen.V52.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V52.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V52.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V52.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V52.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V52.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V52.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V52.Bridge.DeliveryEnvelope Evergreen.V52.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V52.Bridge.DeliveryEnvelope (List Evergreen.V52.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V52.DimensionalModel.DimensionalModelRef Evergreen.V52.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V52.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
