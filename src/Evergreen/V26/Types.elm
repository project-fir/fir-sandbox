module Evergreen.V26.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V26.Bridge
import Evergreen.V26.DimensionalModel
import Evergreen.V26.DuckDb
import Evergreen.V26.Gen.Pages
import Evergreen.V26.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V26.Shared.Model
    , page : Evergreen.V26.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V26.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V26.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V26.Shared.Msg
    | Page Evergreen.V26.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V26.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V26.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V26.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V26.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V26.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V26.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V26.Bridge.DeliveryEnvelope Evergreen.V26.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V26.Bridge.DeliveryEnvelope (List Evergreen.V26.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V26.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
