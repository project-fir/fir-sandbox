module Evergreen.V40.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V40.Bridge
import Evergreen.V40.DimensionalModel
import Evergreen.V40.DuckDb
import Evergreen.V40.Gen.Pages
import Evergreen.V40.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V40.Shared.Model
    , page : Evergreen.V40.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V40.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V40.DimensionalModel.DimensionalModelRef Evergreen.V40.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V40.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V40.Shared.Msg
    | Page Evergreen.V40.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V40.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V40.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V40.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V40.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V40.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V40.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V40.Bridge.DeliveryEnvelope Evergreen.V40.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V40.Bridge.DeliveryEnvelope (List Evergreen.V40.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V40.DimensionalModel.DimensionalModelRef Evergreen.V40.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V40.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
