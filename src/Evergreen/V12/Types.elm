module Evergreen.V12.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V12.Bridge
import Evergreen.V12.Gen.Pages
import Evergreen.V12.Shared
import Lamdera
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V12.Shared.Model
    , page : Evergreen.V12.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V12.Shared.Msg
    | Page Evergreen.V12.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V12.Bridge.ToBackend


type BackendMsg
    = NoopBackend


type ToFrontend
    = NoOpToFrontend
