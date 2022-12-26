module Evergreen.V61.Pages.Admin exposing (..)

import Dict
import Evergreen.V61.Bridge
import Evergreen.V61.DimensionalModel
import Lamdera


type alias Model =
    { backendModel :
        Maybe
            { sessionIds : List Lamdera.SessionId
            , dimensionalModels : Dict.Dict Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DimensionalModel.DimensionalModel
            , duckDbCache : Evergreen.V61.Bridge.DuckDbCache_
            }
    , dateDimStartDate : String
    , dateDimEndDate : String
    , proxiedServerStatus : Maybe String
    , purgedDataStatus : Maybe String
    , cacheRefreshStatus : Maybe String
    , selectedDimModel : Maybe Evergreen.V61.DimensionalModel.DimensionalModel
    , dateDimTaskResponse : Maybe String
    }


type DateDimFormField
    = StartDate
    | EndDate


type Msg
    = RefetchBackendData
    | PurgeBackendData
    | UserClickedRefreshBackendCache
    | ProxyServerPingToBackend
    | UserChangedDateDimForm DateDimFormField String
    | ProxyTask_DateDimTable String String
    | GotTask_DateDimResponse String
    | GotPurgeDataConfirmation String
    | GotCacheRefreshConfirmation String
    | GotProxiedServerPingStatus String
    | UserClickedDimModelRow Evergreen.V61.DimensionalModel.DimensionalModelRef
    | GotBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V61.Bridge.DuckDbCache_
        }
