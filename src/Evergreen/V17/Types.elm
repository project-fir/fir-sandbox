module Evergreen.V17.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V17.Bridge
import Evergreen.V17.DimensionalModel
import Evergreen.V17.DuckDb
import Evergreen.V17.Gen.Pages
import Evergreen.V17.Shared
import Http
import Lamdera
import RemoteData
import Time
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V17.Shared.Model
    , page : Evergreen.V17.Gen.Pages.Model
    }


type alias Session =
    { userId : Int
    , expires : Time.Posix
    }


type alias ServerPingStatus =
    RemoteData.WebData Evergreen.V17.DuckDb.PingResponse


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    , dimensionalModels : Dict.Dict Evergreen.V17.DimensionalModel.DimensionalModelRef Evergreen.V17.DimensionalModel.DimensionalModel
    , serverPingStatus : ServerPingStatus
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V17.Shared.Msg
    | Page Evergreen.V17.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V17.Bridge.ToBackend


type BackendMsg
    = NoopBackend
    | PingServer
    | GotPingResponse (Result Http.Error Evergreen.V17.DuckDb.PingResponse)


type ToFrontend
    = DeliverDimensionalModelRefs (List Evergreen.V17.DimensionalModel.DimensionalModelRef)
    | DeliverDimensionalModel Evergreen.V17.DimensionalModel.DimensionalModel
    | Noop_Error
    | Admin_DeliverAllBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V17.DimensionalModel.DimensionalModelRef Evergreen.V17.DimensionalModel.DimensionalModel
        }
    | Admin_DeliverServerStatus String
