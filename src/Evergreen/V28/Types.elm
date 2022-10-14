module Evergreen.V28.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V28.Bridge
import Evergreen.V28.DimensionalModel
import Evergreen.V28.DuckDb
import Evergreen.V28.Gen.Pages
import Evergreen.V28.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V28.Shared.Model
    , page : Evergreen.V28.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V28.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V28.DimensionalModel.DimensionalModelRef Evergreen.V28.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V28.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V28.Shared.Msg
    | Page Evergreen.V28.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V28.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V28.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V28.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V28.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V28.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V28.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V28.Bridge.DeliveryEnvelope Evergreen.V28.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V28.Bridge.DeliveryEnvelope (List Evergreen.V28.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V28.DimensionalModel.DimensionalModelRef Evergreen.V28.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V28.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
