module Evergreen.V43.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V43.Bridge
import Evergreen.V43.DimensionalModel
import Evergreen.V43.DuckDb
import Evergreen.V43.Gen.Pages
import Evergreen.V43.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V43.Shared.Model
    , page : Evergreen.V43.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V43.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V43.DimensionalModel.DimensionalModelRef Evergreen.V43.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V43.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V43.Shared.Msg
    | Page Evergreen.V43.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V43.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V43.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V43.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V43.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V43.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V43.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V43.Bridge.DeliveryEnvelope Evergreen.V43.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V43.Bridge.DeliveryEnvelope (List Evergreen.V43.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V43.DimensionalModel.DimensionalModelRef Evergreen.V43.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V43.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
