module Evergreen.V46.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V46.Bridge
import Evergreen.V46.DimensionalModel
import Evergreen.V46.DuckDb
import Evergreen.V46.Gen.Pages
import Evergreen.V46.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V46.Shared.Model
    , page : Evergreen.V46.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V46.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V46.DimensionalModel.DimensionalModelRef Evergreen.V46.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V46.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V46.Shared.Msg
    | Page Evergreen.V46.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V46.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V46.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V46.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V46.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V46.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V46.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V46.Bridge.DeliveryEnvelope Evergreen.V46.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V46.Bridge.DeliveryEnvelope (List Evergreen.V46.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V46.DimensionalModel.DimensionalModelRef Evergreen.V46.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V46.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
