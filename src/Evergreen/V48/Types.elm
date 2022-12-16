module Evergreen.V48.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V48.Bridge
import Evergreen.V48.DimensionalModel
import Evergreen.V48.DuckDb
import Evergreen.V48.Gen.Pages
import Evergreen.V48.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V48.Shared.Model
    , page : Evergreen.V48.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V48.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V48.DimensionalModel.DimensionalModelRef Evergreen.V48.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V48.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V48.Shared.Msg
    | Page Evergreen.V48.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V48.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V48.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V48.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V48.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V48.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V48.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V48.Bridge.DeliveryEnvelope Evergreen.V48.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V48.Bridge.DeliveryEnvelope (List Evergreen.V48.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V48.DimensionalModel.DimensionalModelRef Evergreen.V48.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V48.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
