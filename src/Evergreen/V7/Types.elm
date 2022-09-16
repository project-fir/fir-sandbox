module Evergreen.V7.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V7.Bridge
import Evergreen.V7.Gen.Pages
import Evergreen.V7.Shared
import Lamdera
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V7.Shared.Model
    , page : Evergreen.V7.Gen.Pages.Model
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
    | Shared Evergreen.V7.Shared.Msg
    | Page Evergreen.V7.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V7.Bridge.ToBackend


type BackendMsg
    = NoopBackend


type ToFrontend
    = NoOpToFrontend
