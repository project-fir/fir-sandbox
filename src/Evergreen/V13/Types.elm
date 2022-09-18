module Evergreen.V13.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V13.Bridge
import Evergreen.V13.Gen.Pages
import Evergreen.V13.Shared
import Lamdera
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V13.Shared.Model
    , page : Evergreen.V13.Gen.Pages.Model
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
    | Shared Evergreen.V13.Shared.Msg
    | Page Evergreen.V13.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V13.Bridge.ToBackend


type BackendMsg
    = NoopBackend


type ToFrontend
    = NoOpToFrontend
