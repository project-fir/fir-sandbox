module Evergreen.V38.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V38.Bridge
import Evergreen.V38.DimensionalModel
import Evergreen.V38.DuckDb
import Evergreen.V38.Gen.Pages
import Evergreen.V38.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V38.Shared.Model
    , page : Evergreen.V38.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V38.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V38.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V38.Shared.Msg
    | Page Evergreen.V38.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V38.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V38.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V38.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V38.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V38.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V38.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V38.Bridge.DeliveryEnvelope Evergreen.V38.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V38.Bridge.DeliveryEnvelope (List Evergreen.V38.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V38.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
