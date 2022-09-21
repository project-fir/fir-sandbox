module Types exposing (..)

import Bridge
import Browser
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)
import DuckDb exposing (DuckDbRefString, PingResponse)
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
    }


type
    BackendMsg
    -- TODO: Auth, users, etc
    = NoopBackend
    | PingServer
    | GotPingResponse (Result Http.Error PingResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List DimensionalModelRef)
    | DeliverDimensionalModel DimensionalModel
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List SessionId
        , dimensionalModels : Dict DimensionalModelRef DimensionalModel
        }
    | Admin_DeliverServerStatus String


type alias ToBackend =
    Bridge.ToBackend
