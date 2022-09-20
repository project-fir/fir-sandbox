module Evergreen.V16.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V16.Bridge
import Evergreen.V16.DimensionalModel
import Evergreen.V16.Gen.Pages
import Evergreen.V16.Shared
import Lamdera
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V16.Shared.Model
    , page : Evergreen.V16.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V16.DimensionalModel.DimensionalModelRef Evergreen.V16.DimensionalModel.DimensionalModel
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V16.Shared.Msg
    | Page Evergreen.V16.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V16.Bridge.ToBackend


type BackendMsg
    = NoopBackend


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V16.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel Evergreen.V16.DimensionalModel.DimensionalModel
    | Noop_Error
