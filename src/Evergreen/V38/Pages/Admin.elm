module Evergreen.V38.Pages.Admin exposing (..)

import Dict
import Evergreen.V38.Bridge
import Evergreen.V38.DimensionalModel
import Lamdera


type alias Model =
    { backendModel :
        Maybe
            { sessionIds : List Lamdera.SessionId
            , dimensionalModels : Dict.Dict Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DimensionalModel.DimensionalModel
            , duckDbCache : Evergreen.V38.Bridge.DuckDbCache_
            }
    , dateDimStartDate : String
    , dateDimEndDate : String
    , proxiedServerStatus : Maybe String
    , purgedDataStatus : Maybe String
    , cacheRefreshStatus : Maybe String
    , selectedDimModel : Maybe Evergreen.V38.DimensionalModel.DimensionalModel
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
    | UserClickedDimModelRow Evergreen.V38.DimensionalModel.DimensionalModelRef
    | GotBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V38.Bridge.DuckDbCache_
        }
