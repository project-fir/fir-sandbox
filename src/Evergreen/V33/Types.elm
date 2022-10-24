module Evergreen.V33.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V33.Bridge
import Evergreen.V33.DimensionalModel
import Evergreen.V33.DuckDb
import Evergreen.V33.Gen.Pages
import Evergreen.V33.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V33.Shared.Model
    , page : Evergreen.V33.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V33.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V33.DimensionalModel.DimensionalModelRef Evergreen.V33.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V33.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V33.Shared.Msg
    | Page Evergreen.V33.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V33.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V33.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V33.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V33.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V33.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V33.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V33.Bridge.DeliveryEnvelope Evergreen.V33.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V33.Bridge.DeliveryEnvelope (List Evergreen.V33.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V33.DimensionalModel.DimensionalModelRef Evergreen.V33.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V33.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
