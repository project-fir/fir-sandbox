module Evergreen.V61.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V61.Bridge
import Evergreen.V61.DimensionalModel
import Evergreen.V61.DuckDb
import Evergreen.V61.Gen.Pages
import Evergreen.V61.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V61.Shared.Model
    , page : Evergreen.V61.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V61.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V61.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V61.Shared.Msg
    | Page Evergreen.V61.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V61.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V61.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V61.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V61.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V61.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V61.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V61.Bridge.DeliveryEnvelope Evergreen.V61.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V61.Bridge.DeliveryEnvelope (List Evergreen.V61.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V61.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
