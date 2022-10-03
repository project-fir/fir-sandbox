module Evergreen.V26.Pages.Admin exposing (..)

import Dict
import Evergreen.V26.Bridge
import Evergreen.V26.DimensionalModel
import Lamdera


type alias Model =
    { backendModel :
        Maybe
            { sessionIds : List Lamdera.SessionId
            , dimensionalModels : Dict.Dict Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DimensionalModel.DimensionalModel
            , duckDbCache : Evergreen.V26.Bridge.DuckDbCache_
            }
    , dateDimStartDate : String
    , dateDimEndDate : String
    , proxiedServerStatus : Maybe String
    , purgedDataStatus : Maybe String
    , cacheRefreshStatus : Maybe String
    , selectedDimModel : Maybe Evergreen.V26.DimensionalModel.DimensionalModel
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
    | UserClickedDimModelRow Evergreen.V26.DimensionalModel.DimensionalModelRef
    | GotBackendData
        { sessionIds : List Lamdera.SessionId
        , dimensionalModels : Dict.Dict Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DimensionalModel.DimensionalModel
        , duckDbCache : Evergreen.V26.Bridge.DuckDbCache_
        }
