module Types exposing (..)

import Bridge
import Browser
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Gen.Pages as Pages
import Lamdera exposing (ClientId, SessionId)
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


type alias BackendModel =
    { sessions : Dict SessionId Session
    }


type
    BackendMsg
    -- TODO: Auth, users, etc
    = NoopBackend


type
    ToFrontend
    -- TODO: Replace me, Do I need Bridge.elm?
    = NoOpToFrontend



--| PageMsg Pages.Msg


type alias ToBackend =
    Bridge.ToBackend
