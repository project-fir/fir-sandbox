module Evergreen.V22.Pages.Admin exposing (..)

import Dict
import Evergreen.V22.Bridge
import Evergreen.V22.DimensionalModel
import Lamdera


type alias Model =
    { backendModel :
        Maybe
            { sessionIds : List Lamdera.SessionId
            , dimensionalModels : Dict.Dict Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DimensionalModel.DimensionalModel
            , duckDbCache : Evergreen.V22.Bridge.DuckDbCache_
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
        , dimensionalModels : Dict.Dict Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V22.Bridge.DuckDbCache_
        }
