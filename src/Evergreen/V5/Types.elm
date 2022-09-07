module Evergreen.V5.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V5.Bridge
import Evergreen.V5.Gen.Pages
import Evergreen.V5.Shared
import Lamdera
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V5.Shared.Model
    , page : Evergreen.V5.Gen.Pages.Model
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
    | Shared Evergreen.V5.Shared.Msg
    | Page Evergreen.V5.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V5.Bridge.ToBackend


type BackendMsg
    = NoopBackend


type ToFrontend
    = NoOpToFrontend
