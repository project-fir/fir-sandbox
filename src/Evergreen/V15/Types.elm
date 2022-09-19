module Evergreen.V15.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V15.Bridge
import Evergreen.V15.DimensionalModel
import Evergreen.V15.Gen.Pages
import Evergreen.V15.Shared
import Lamdera
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V15.Shared.Model
    , page : Evergreen.V15.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V15.DimensionalModel.DimensionalModelRef Evergreen.V15.DimensionalModel.DimensionalModel
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V15.Shared.Msg
    | Page Evergreen.V15.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V15.Bridge.ToBackend


type BackendMsg
    = NoopBackend


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V15.DimensionalModel.DimensionalModelRef)
