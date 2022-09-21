module Evergreen.V18.Pages.Admin exposing (..)

import Dict
import Evergreen.V18.Bridge
import Evergreen.V18.DimensionalModel
import Lamdera


type alias Model =
    { backendModel :
        Maybe
            { sessionIds : List Lamdera.SessionId
            , dimensionalModels : Dict.Dict Evergreen.V18.DimensionalModel.DimensionalModelRef Evergreen.V18.DimensionalModel.DimensionalModel
            , duckDbCache : Evergreen.V18.Bridge.DuckDbCache_
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
        , dimensionalModels : Dict.Dict Evergreen.V18.DimensionalModel.DimensionalModelRef Evergreen.V18.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V18.Bridge.DuckDbCache_
        }
