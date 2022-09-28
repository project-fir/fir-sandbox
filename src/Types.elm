module Types exposing (..)

import Bridge exposing (BackendData, BackendErrorMessage, DeliveryEnvelope, DuckDbCache_, DuckDbMetaDataCacheEntry)
import Browser
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelEdge, DimensionalModelRef, KimballAssignment, PositionPx)
import DuckDb exposing (DuckDbColumnDescription, DuckDbMetaResponse, DuckDbRef, DuckDbRefString, DuckDbRef_, DuckDbRefsResponse, PingResponse)
import Gen.Pages as Pages
import Graph exposing (Graph)
import Http
import Lamdera exposing (ClientId, SessionId)
import RemoteData exposing (WebData)
import Shared
import Time
import Url exposing (Url)


type alias FrontendModel =
    { url : Url
    , key : Key
    , shared : Shared.Model
    , page : Pages.Model
    }


type alias Session =
    { userId : Int, expires : Time.Posix }


type alias UserId =
    Int


type alias UserFull =
    { id : UserId
    }


type FrontendMsg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | Shared Shared.Msg
    | Page Pages.Msg
    | Noop


type alias ServerPingStatus =
    WebData PingResponse


type alias BackendModel =
    { sessions : Dict SessionId Session
    , dimensionalModels : Dict DimensionalModelRef DimensionalModel
    , serverPingStatus : ServerPingStatus
    , duckDbCache : DuckDbCache_
    }


type
    BackendMsg
    -- TODO: Auth, users, etc
    = BackendNoop
    | PingServer
    | GotPingResponse (Result Http.Error PingResponse)
    | Cache_BeginWarmingCycle
    | Cache_ContinueCacheWarmingInProgress
    | Cache_GotDuckDbRefsResponse (Result Http.Error DuckDbRefsResponse)
    | Cache_GotDuckDbMetaDataResponse (Result Http.Error DuckDbMetaResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List DimensionalModelRef)
    | DeliverDimensionalModel (DeliveryEnvelope DimensionalModel)
    | DeliverDuckDbRefs (DeliveryEnvelope (List DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List SessionId
        , dimensionalModels : Dict DimensionalModelRef DimensionalModel
        , duckDbCache : DuckDbCache_
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String


type alias ToBackend =
    Bridge.ToBackend



-- TODO: Implement "dimensional model API"
