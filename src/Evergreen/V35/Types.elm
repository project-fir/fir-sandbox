module Evergreen.V35.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V35.Bridge
import Evergreen.V35.DimensionalModel
import Evergreen.V35.DuckDb
import Evergreen.V35.Gen.Pages
import Evergreen.V35.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V35.Shared.Model
    , page : Evergreen.V35.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V35.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V35.DimensionalModel.DimensionalModelRef Evergreen.V35.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V35.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V35.Shared.Msg
    | Page Evergreen.V35.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V35.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V35.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V35.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V35.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V35.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V35.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V35.Bridge.DeliveryEnvelope Evergreen.V35.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V35.Bridge.DeliveryEnvelope (List Evergreen.V35.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V35.DimensionalModel.DimensionalModelRef Evergreen.V35.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V35.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
