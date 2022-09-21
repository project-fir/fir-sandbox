module Evergreen.V17.Pages.Admin exposing (..)

import Dict
import Evergreen.V17.DimensionalModel
import Lamdera


type alias Model =
    { backendModel :
        Maybe
            { sessionIds : List Lamdera.SessionId
            , dimensionalModels : Dict.Dict Evergreen.V17.DimensionalModel.DimensionalModelRef Evergreen.V17.DimensionalModel.DimensionalModel
            }
    , proxiedServerStatus : Maybe String
    }


type Msg
    = RefetchBackendData
    | ProxyServerPingToBackend
    | GotProxiedServerPingStatus String
    | GotBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V17.DimensionalModel.DimensionalModelRef Evergreen.V17.DimensionalModel.DimensionalModel
        }
