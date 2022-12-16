module Evergreen.V49.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V49.Bridge
import Evergreen.V49.DimensionalModel
import Evergreen.V49.DuckDb
import Evergreen.V49.Gen.Pages
import Evergreen.V49.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V49.Shared.Model
    , page : Evergreen.V49.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V49.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V49.DimensionalModel.DimensionalModelRef Evergreen.V49.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V49.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V49.Shared.Msg
    | Page Evergreen.V49.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V49.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V49.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V49.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V49.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V49.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V49.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V49.Bridge.DeliveryEnvelope Evergreen.V49.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V49.Bridge.DeliveryEnvelope (List Evergreen.V49.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V49.DimensionalModel.DimensionalModelRef Evergreen.V49.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V49.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
