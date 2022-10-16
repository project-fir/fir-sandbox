module Evergreen.V29.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V29.Bridge
import Evergreen.V29.DimensionalModel
import Evergreen.V29.DuckDb
import Evergreen.V29.Gen.Pages
import Evergreen.V29.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V29.Shared.Model
    , page : Evergreen.V29.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V29.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V29.DimensionalModel.DimensionalModelRef Evergreen.V29.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V29.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V29.Shared.Msg
    | Page Evergreen.V29.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V29.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V29.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V29.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V29.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V29.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V29.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V29.Bridge.DeliveryEnvelope Evergreen.V29.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V29.Bridge.DeliveryEnvelope (List Evergreen.V29.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V29.DimensionalModel.DimensionalModelRef Evergreen.V29.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V29.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
