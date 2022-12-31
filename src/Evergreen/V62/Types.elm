module Evergreen.V62.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V62.Bridge
import Evergreen.V62.DimensionalModel
import Evergreen.V62.DuckDb
import Evergreen.V62.Gen.Pages
import Evergreen.V62.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V62.Shared.Model
    , page : Evergreen.V62.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V62.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : Evergreen.V62.Bridge.DuckDbCache_
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V62.Shared.Msg
    | Page Evergreen.V62.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V62.Bridge.ToBackend


type BackendMsg
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V62.DuckDb.PingResponse)
    | BeginTask_BuildDateDim String String
    | GotTaskResponse (Result Http.Error Evergreen.V62.DuckDb.PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error Evergreen.V62.DuckDb.DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error Evergreen.V62.DuckDb.DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V62.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel (Evergreen.V62.Bridge.DeliveryEnvelope Evergreen.V62.DimensionalModel.DimensionalModel)
    | DeliverDuckDbRefs (Evergreen.V62.Bridge.DeliveryEnvelope (List Evergreen.V62.DuckDb.DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V62.Bridge.DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String
    | Admin_DeliverTaskDateDimResponse String
