module Evergreen.V21.Pages.Admin exposing (..)

import Dict
import Evergreen.V21.Bridge
import Evergreen.V21.DimensionalModel
import Lamdera


type alias Model =
    { backendModel :
        Maybe
            { sessionIds : List Lamdera.SessionId
            , dimensionalModels : Dict.Dict Evergreen.V21.DimensionalModel.DimensionalModelRef Evergreen.V21.DimensionalModel.DimensionalModel
            , duckDbCache : Evergreen.V21.Bridge.DuckDbCache_
            }
    , proxiedServerStatus : Maybe String
    , purgedDataStatus : Maybe String
    , cacheRefreshStatus : Maybe String
    }


type Msg
    = RefetchBackendData
    | PurgeBackendData
    | UserClickedRefreshBackendCache
    | ProxyServerPingToBackend
    | GotPurgeDataConfirmation String
    | GotCacheRefreshConfirmation String
    | GotProxiedServerPingStatus String
    | GotBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V21.DimensionalModel.DimensionalModelRef Evergreen.V21.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V21.Bridge.DuckDbCache_
        }
