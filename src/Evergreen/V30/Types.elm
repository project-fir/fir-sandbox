module Evergreen.V30.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V30.Bridge
import Evergreen.V30.DimensionalModel
import Evergreen.V30.DuckDb
import Evergreen.V30.Gen.Pages
import Evergreen.V30.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V30.Shared.Model
    , page : Evergreen.V30.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V30.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V30.DimensionalModel.DimensionalModelRef Evergreen.V30.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V30.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V30.Shared.Msg
    | Page Evergreen.V30.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V30.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V30.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V30.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V30.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V30.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V30.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V30.Bridge.DeliveryEnvelope Evergreen.V30.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V30.Bridge.DeliveryEnvelope (List Evergreen.V30.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V30.DimensionalModel.DimensionalModelRef Evergreen.V30.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V30.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
