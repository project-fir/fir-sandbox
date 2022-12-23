module Evergreen.V56.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V56.Bridge
import Evergreen.V56.DimensionalModel
import Evergreen.V56.DuckDb
import Evergreen.V56.Gen.Pages
import Evergreen.V56.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V56.Shared.Model
    , page : Evergreen.V56.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V56.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V56.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V56.Shared.Msg
    | Page Evergreen.V56.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V56.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V56.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V56.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V56.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V56.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V56.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V56.Bridge.DeliveryEnvelope Evergreen.V56.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V56.Bridge.DeliveryEnvelope (List Evergreen.V56.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V56.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
