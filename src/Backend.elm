module Backend exposing (..)

import Bridge exposing (BackendErrorMessage(..), DeliveryEnvelope(..), DuckDbCache, DuckDbCache_(..), ToBackend(..), defaultColdCache)
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef, KimballAssignment(..), PositionPx, TableRenderInfo)
import DuckDb exposing (DuckDbColumnDescription, DuckDbRef, DuckDbRefString, DuckDbRef_(..), fetchDuckDbTableRefs, pingServer, queryDuckDbMeta, refToString)
import Graph
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import RemoteData exposing (RemoteData(..))
import Task
import Types exposing (BackendModel, BackendMsg(..), FrontendMsg(..), Session, ToFrontend(..))
import Utils exposing (send)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { sessions = Dict.empty
      , dimensionalModels = Dict.empty
      , serverPingStatus = NotAsked
      , duckDbCache = Cold defaultColdCache
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        PingServer ->
            ( { model | serverPingStatus = Loading }, pingServer GotPingResponse )

        GotPingResponse result ->
            case result of
                Ok value ->
                    ( { model | serverPingStatus = Success value }, broadcast (Admin_DeliverServerStatus "OK") )

                Err error ->
                    ( { model | serverPingStatus = Failure error }, broadcast (Admin_DeliverServerStatus "ERROR!") )

        -- begin region: cache warming cycle
        Cache_BeginWarmingCycle ->
            case model.duckDbCache of
                Cold cacheSnapshot ->
                    ( { model | duckDbCache = WarmingCycleInitiated cacheSnapshot }, fetchDuckDbTableRefs Cache_GotDuckDbRefsResponse )

                Hot cacheSnapshot ->
                    -- Begin warming cycle, but pass along existing cached values, so user can still read stale data
                    -- as the cache is being refreshed.
                    ( { model | duckDbCache = WarmingCycleInitiated cacheSnapshot }, fetchDuckDbTableRefs Cache_GotDuckDbRefsResponse )

                WarmingCycleInitiated _ ->
                    -- TODO: Race condition send to admin, cache refresh already in progress
                    ( model, Cmd.none )

                Warming _ _ _ ->
                    -- TODO: Race condition send to admin, cache refresh already in progress
                    ( model, Cmd.none )

        Cache_GotDuckDbRefsResponse response ->
            -- Special case, this should only occur after the first HTTP call of the cache warming cycle
            case response of
                Ok refsResponse ->
                    case model.duckDbCache of
                        WarmingCycleInitiated oldCache ->
                            ( { model | duckDbCache = Warming oldCache defaultColdCache refsResponse.refs }, send Cache_ContinueCacheWarmingInProgress )

                        _ ->
                            -- TODO: Send error messaging to frontend
                            ( { model | duckDbCache = Cold defaultColdCache }, Cmd.none )

                Err error ->
                    -- TODO: Send error messaging to frontend
                    ( { model | duckDbCache = Cold defaultColdCache }, Cmd.none )

        Cache_ContinueCacheWarmingInProgress ->
            case model.duckDbCache of
                Warming oldCache partialInProgressCache remainingRefs ->
                    case remainingRefs of
                        [] ->
                            ( { model | duckDbCache = Hot partialInProgressCache }
                            , broadcast (Admin_DeliverCacheRefreshConfirmation "complete!")
                            )

                        r :: rs ->
                            let
                                queryStr : String
                                queryStr =
                                    "select * from " ++ refToString r
                            in
                            ( { model | duckDbCache = Warming oldCache partialInProgressCache rs }
                            , queryDuckDbMeta queryStr True [ r ] Cache_GotDuckDbMetaDataResponse
                            )

                _ ->
                    -- TODO: Send error messaging to frontend
                    ( { model | duckDbCache = Cold defaultColdCache }, Cmd.none )

        Cache_GotDuckDbMetaDataResponse response ->
            case response of
                Ok responseData ->
                    case responseData.refs of
                        [] ->
                            -- TODO: Send error messaging to frontend
                            ( { model | duckDbCache = Cold defaultColdCache }, Cmd.none )

                        r :: _ ->
                            case model.duckDbCache of
                                Warming oldCache partialCache remainingRefs ->
                                    let
                                        updatedPartialCache : DuckDbCache
                                        updatedPartialCache =
                                            { refs = r :: partialCache.refs
                                            , metaData =
                                                Dict.insert (refToString r)
                                                    { ref = r
                                                    , columnDescriptions = responseData.columnDescriptions
                                                    }
                                                    partialCache.metaData
                                            }
                                    in
                                    ( { model | duckDbCache = Warming oldCache updatedPartialCache remainingRefs }
                                    , send Cache_ContinueCacheWarmingInProgress
                                    )

                                _ ->
                                    -- TODO: Send error messaging to frontend
                                    ( { model | duckDbCache = Cold defaultColdCache }, Cmd.none )

                Err error ->
                    -- TODO: Send error messaging to frontend
                    ( { model | duckDbCache = Cold defaultColdCache }, Cmd.none )

        -- end region: cache warming cycle
        BackendNoop ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        FetchDimensionalModelRefs ->
            let
                refs : List DimensionalModelRef
                refs =
                    Dict.keys model.dimensionalModels
            in
            ( model, sendToFrontend clientId (DeliverDimensionalModelRefs refs) )

        CreateNewDimensionalModel ref ->
            -- Check if we already have a model of this name
            case Dict.member ref model.dimensionalModels of
                -- We do, don't overwrite data!
                True ->
                    -- TODO: Once I have a few more cases like this I'd like to establish a pattern for Lamdera
                    --      error handling, but this NoOp prevents data from being accidentally overwritten for now
                    ( model, Cmd.none )

                False ->
                    -- We don't, update collection with new ref, send full key list back to client
                    let
                        newDimModels : Dict DimensionalModelRef DimensionalModel
                        newDimModels =
                            Dict.insert ref
                                { selectedDbRefs = []
                                , tableInfos = defaultTableInfos model.duckDbCache
                                , graph = Graph.empty
                                , ref = ref
                                }
                                model.dimensionalModels

                        newRefs : List DimensionalModelRef
                        newRefs =
                            Dict.keys newDimModels
                    in
                    ( { model | dimensionalModels = newDimModels }, broadcast (DeliverDimensionalModelRefs newRefs) )

        FetchDimensionalModel ref ->
            case Dict.get ref model.dimensionalModels of
                -- We do, don't overwrite data!
                Just dimModel ->
                    ( model, sendToFrontend clientId (DeliverDimensionalModel dimModel) )

                Nothing ->
                    -- TODO: Once I have a few more cases like this I'd like to establish a pattern for Lamdera errors
                    ( model, Cmd.none )

        UpdateDimensionalModel newDimModel ->
            case Dict.member newDimModel.ref model.dimensionalModels of
                True ->
                    let
                        updatedDimModels : Dict DimensionalModelRef DimensionalModel
                        updatedDimModels =
                            Dict.insert newDimModel.ref newDimModel model.dimensionalModels
                    in
                    -- TODO: user-scoped broadcasting, needs auth
                    ( { model | dimensionalModels = updatedDimModels }, sendToFrontend clientId (DeliverDimensionalModel newDimModel) )

                False ->
                    -- TODO: Once I have a few more cases like this I'd like to establish a pattern for Lamdera
                    --      error handling, but this NoOp is safe for now
                    ( model, sendToFrontend clientId Noop_Error )

        Admin_FetchAllBackendData ->
            let
                sessionIds =
                    Dict.keys model.sessions
            in
            ( model
            , sendToFrontend clientId
                (Admin_DeliverAllBackendData
                    { sessionIds = sessionIds
                    , dimensionalModels = model.dimensionalModels
                    , duckDbCache = model.duckDbCache
                    }
                )
            )

        Admin_PingServer ->
            ( model, send PingServer )

        Admin_InitiateDuckDbCacheWarmingCycle ->
            ( model, send Cache_BeginWarmingCycle )

        Admin_PurgeBackendData ->
            let
                newModel : BackendModel
                newModel =
                    { sessions = model.sessions -- keep active sessions, otherwise you may need to re-auth etc. That'd be weird
                    , dimensionalModels = Dict.empty
                    , serverPingStatus = NotAsked -- in theory there's a race condition here if a server ping is in progress, not worth doing it right
                    , duckDbCache = Cold defaultColdCache
                    }
            in
            ( newModel, sendToFrontend clientId (Admin_DeliverPurgeConfirmation "All data has been purged") )

        Kimball_FetchDuckDbRefs ->
            case model.duckDbCache of
                Cold cache ->
                    ( model, sendToFrontend clientId (DeliverDuckDbRefs (BackendSuccess cache.refs)) )

                WarmingCycleInitiated oldDuckDbCache ->
                    -- User should't care that a cache warming cycle is in progress, return old values
                    ( model, sendToFrontend clientId (DeliverDuckDbRefs (BackendSuccess oldDuckDbCache.refs)) )

                Warming oldDuckDbCache _ _ ->
                    -- User should't care that a cache warming cycle is in progress, return old values
                    ( model, sendToFrontend clientId (DeliverDuckDbRefs (BackendSuccess oldDuckDbCache.refs)) )

                Hot cache ->
                    ( model, sendToFrontend clientId (DeliverDuckDbRefs (BackendSuccess cache.refs)) )


defaultTableInfos :
    DuckDbCache_
    -> Dict DuckDbRefString ( TableRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) )
defaultTableInfos cache =
    let
        startingPositions : DuckDbCache -> List PositionPx
        startingPositions cache_ =
            -- TODO: Is random better? Mod 10? This impact default layout user sees, so it might be worth spending time
            --       here on something fancier.
            List.map (\i -> { x = toFloat <| 100 * i, y = toFloat <| 100 * i }) (List.range 0 (List.length cache_.refs - 1))

        startingKimballAssignments : DuckDbCache -> List (KimballAssignment DuckDbRef_ (List DuckDbColumnDescription))
        startingKimballAssignments cache_ =
            List.map (\entry -> Unassigned (DuckDbTable entry.ref) entry.columnDescriptions) (Dict.values cache_.metaData)

        result : DuckDbCache -> Dict DuckDbRefString ( TableRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) )
        result cache_ =
            Dict.fromList <|
                List.map3 (\ref pos assignment -> ( refToString ref, ( { pos = pos, ref = ref }, assignment ) )) cache_.refs (startingPositions cache_) (startingKimballAssignments cache_)
    in
    case cache of
        Cold duckDbCache ->
            result duckDbCache

        WarmingCycleInitiated duckDbCache ->
            result duckDbCache

        Warming duckDbCache _ _ ->
            result duckDbCache

        Hot duckDbCache ->
            result duckDbCache
