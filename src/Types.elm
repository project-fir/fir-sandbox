module Types exposing (..)

import Bridge exposing (BackendData, BackendErrorMessage, DeliveryEnvelope)
import Browser
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)
import DuckDb exposing (DuckDbColumnDescription, DuckDbMetaResponse, DuckDbRef, DuckDbRefString, DuckDbRefsResponse, PingResponse)
import Gen.Pages as Pages
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
    , duckDbCache : Maybe DuckDbCache
    , partialDuckDbCacheInProgress : Maybe DuckDbCache
    , partialRemainingRefs : Maybe (List DuckDbRef)
    }


type
    BackendMsg
    -- TODO: Auth, users, etc
    = NoopBackend
    | PingServer
    | BeginDuckDbCacheRefresh
    | ContinueDuckDbCacheRefresh
    | CompleteDuckDbCacheRefresh
    | GotPingResponse (Result Http.Error PingResponse)
    | GotDuckDbRefsResponse (Result Http.Error DuckDbRefsResponse)
    | GotDuckDbMetaDataResponse (Result Http.Error DuckDbMetaResponse)


type alias CachedDuckDbMetaData =
    { ref : DuckDbRef
    , columnDescriptions : List DuckDbColumnDescription
    }


type alias DuckDbCache =
    { refs : List DuckDbRef
    , metaData : Dict DuckDbRefString CachedDuckDbMetaData
    }


type ToFrontend
    = DeliverDimensionalModelRefs (List DimensionalModelRef)
    | DeliverDimensionalModel DimensionalModel
    | DeliverDuckDbRefs (DeliveryEnvelope (List DuckDbRef))
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List SessionId
        , dimensionalModels : Dict DimensionalModelRef DimensionalModel
        }
    | Admin_DeliverServerStatus String
    | Admin_DeliverPurgeConfirmation String
    | Admin_DeliverCacheRefreshConfirmation String


type alias ToBackend =
    Bridge.ToBackend
