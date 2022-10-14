module Backend exposing (..)

import Bridge exposing (BackendErrorMessage, DeliveryEnvelope(..), DimensionalModelUpdate(..), DuckDbCache, DuckDbCache_(..), DuckDbMetaDataCacheEntry, ToBackend(..), defaultColdCache)
import Dict exposing (Dict)
import DimensionalModel exposing (CardRenderInfo, DimModelDuckDbSourceInfo, DimensionalModel, DimensionalModelRef, KimballAssignment(..), PositionPx)
import DuckDb exposing (DuckDbColumnDescription, DuckDbRef, DuckDbRefString, DuckDbRef_(..), fetchDuckDbTableRefs, pingServer, queryDuckDbMeta, refToString, taskBuildDateDimTable)
import Graph
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Pages.Admin exposing (Msg(..))
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


defaultDateDimRef : DuckDbRef
defaultDateDimRef =
    { schemaName = "dwtk", tableName = "date_dim" }


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        BeginTask_BuildDateDim startDate endDate ->
            ( model, taskBuildDateDimTable startDate endDate defaultDateDimRef GotTaskResponse )

        GotTaskResponse result ->
            case result of
                Ok response ->
                    ( model, broadcast (Admin_DeliverTaskDateDimResponse response.message) )

                Err err ->
                    ( model, Cmd.none )

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
                                    "select * from " ++ refToString r ++ " limit 0"
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

                -- We don't, update collection with new ref, send full key list back to client
                False ->
                    let
                        newDimModels : Dict DimensionalModelRef DimensionalModel
                        newDimModels =
                            Dict.insert ref
                                { tableInfos = Dict.empty
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
                Just dimModel ->
                    ( model
                    , sendToFrontend clientId (DeliverDimensionalModel (BackendSuccess dimModel))
                    )

                Nothing ->
                    -- TODO: Once I have a few more cases like this I'd like to establish a pattern for Lamdera errors
                    ( model, Cmd.none )

        UpdateDimensionalModel updateVariant ->
            case updateVariant of
                FullReplacement dimRef dimModel ->
                    ( { model | dimensionalModels = Dict.insert dimRef dimModel model.dimensionalModels }
                    , sendToFrontend clientId (DeliverDimensionalModel (BackendSuccess dimModel))
                    )

                AddDuckDbRefToModel dimRef duckDbRef ->
                    case Dict.get dimRef model.dimensionalModels of
                        Just dimModel ->
                            case Dict.get (refToString duckDbRef) dimModel.tableInfos of
                                Just dimModelSourceInfo ->
                                    -- TODO: We already have an entry, Error??
                                    ( model, Cmd.none )

                                Nothing ->
                                    let
                                        colDescs : List DuckDbColumnDescription
                                        colDescs =
                                            let
                                                lookup : DuckDbCache -> List DuckDbColumnDescription
                                                lookup cache =
                                                    case Dict.get (refToString duckDbRef) cache.metaData of
                                                        Nothing ->
                                                            []

                                                        Just entry ->
                                                            entry.columnDescriptions
                                            in
                                            case model.duckDbCache of
                                                Cold cache ->
                                                    lookup cache

                                                WarmingCycleInitiated cache ->
                                                    lookup cache

                                                Warming cache _ _ ->
                                                    lookup cache

                                                Hot cache ->
                                                    lookup cache

                                        defaultInfo : DimModelDuckDbSourceInfo
                                        defaultInfo =
                                            { renderInfo =
                                                { ref = duckDbRef
                                                , pos = { x = 100, y = 100 }
                                                }
                                            , assignment = Unassigned (DuckDbTable duckDbRef) colDescs
                                            , isIncluded = True
                                            }

                                        newDimModel : DimensionalModel
                                        newDimModel =
                                            { dimModel | tableInfos = Dict.insert (refToString duckDbRef) defaultInfo dimModel.tableInfos }
                                    in
                                    ( { model | dimensionalModels = Dict.insert dimRef newDimModel model.dimensionalModels }
                                    , sendToFrontend clientId (DeliverDimensionalModel (BackendSuccess newDimModel))
                                    )

                        Nothing ->
                            ( model, sendToFrontend clientId (DeliverDimensionalModel (BackendError ("dimModelRef '" ++ dimRef ++ "' requested but not found"))) )

                UpdateNodePosition dimRef duckDbRef positionPx ->
                    case Dict.get dimRef model.dimensionalModels of
                        Just dimModel ->
                            case Dict.get (refToString duckDbRef) dimModel.tableInfos of
                                Just info ->
                                    let
                                        renderInfo : CardRenderInfo
                                        renderInfo =
                                            info.renderInfo

                                        newRenderInfo : CardRenderInfo
                                        newRenderInfo =
                                            { renderInfo | pos = positionPx }

                                        newInfo : DimModelDuckDbSourceInfo
                                        newInfo =
                                            { info | renderInfo = newRenderInfo }

                                        newDimModel : DimensionalModel
                                        newDimModel =
                                            { dimModel | tableInfos = Dict.insert (refToString duckDbRef) newInfo dimModel.tableInfos }
                                    in
                                    ( { model | dimensionalModels = Dict.insert dimRef newDimModel model.dimensionalModels }
                                    , sendToFrontend clientId (DeliverDimensionalModel (BackendSuccess newDimModel))
                                    )

                                Nothing ->
                                    ( model, sendToFrontend clientId (DeliverDimensionalModel (BackendError ("duckdb ref '" ++ refToString duckDbRef ++ "' not found"))) )

                        Nothing ->
                            ( model, sendToFrontend clientId (DeliverDimensionalModel (BackendError ("model of ref '" ++ dimRef ++ "' not found"))) )

                UpdateAssignment dimRef duckDbRef kimballAssignment ->
                    case Dict.get dimRef model.dimensionalModels of
                        Just dimModel ->
                            case Dict.get (refToString duckDbRef) dimModel.tableInfos of
                                Just info ->
                                    let
                                        newInfo : DimModelDuckDbSourceInfo
                                        newInfo =
                                            { info | assignment = kimballAssignment }

                                        newInfos : Dict DuckDbRefString DimModelDuckDbSourceInfo
                                        newInfos =
                                            Dict.insert (refToString duckDbRef) newInfo dimModel.tableInfos

                                        newDimModel : DimensionalModel
                                        newDimModel =
                                            { dimModel | tableInfos = newInfos }
                                    in
                                    ( { model | dimensionalModels = Dict.insert dimRef newDimModel model.dimensionalModels }
                                    , sendToFrontend clientId (DeliverDimensionalModel (BackendSuccess newDimModel))
                                    )

                                Nothing ->
                                    ( model, sendToFrontend clientId (DeliverDimensionalModel (BackendError ("duckdb ref '" ++ refToString duckDbRef ++ "' not found"))) )

                        Nothing ->
                            ( model, sendToFrontend clientId (DeliverDimensionalModel (BackendError ("model of ref '" ++ dimRef ++ "' not found"))) )

                UpdateGraph dimRef graph ->
                    case Dict.get dimRef model.dimensionalModels of
                        Just dimModel ->
                            let
                                newDimModel : DimensionalModel
                                newDimModel =
                                    { dimModel | graph = graph }
                            in
                            ( { model | dimensionalModels = Dict.insert dimRef newDimModel model.dimensionalModels }
                            , sendToFrontend clientId (DeliverDimensionalModel (BackendSuccess newDimModel))
                            )

                        Nothing ->
                            ( model, sendToFrontend clientId (DeliverDimensionalModel (BackendError ("model of ref '" ++ dimRef ++ "' not found"))) )

                ToggleIncludedNode dimModelRef duckDbRef ->
                    case Dict.get dimModelRef model.dimensionalModels of
                        Just dimModel ->
                            case Dict.get (refToString duckDbRef) dimModel.tableInfos of
                                Just info ->
                                    let
                                        newInfo : DimModelDuckDbSourceInfo
                                        newInfo =
                                            { info | isIncluded = not info.isIncluded }

                                        newInfos : Dict DuckDbRefString DimModelDuckDbSourceInfo
                                        newInfos =
                                            Dict.insert (refToString duckDbRef) newInfo dimModel.tableInfos

                                        newDimModel : DimensionalModel
                                        newDimModel =
                                            { dimModel | tableInfos = newInfos }
                                    in
                                    ( { model | dimensionalModels = Dict.insert dimModelRef newDimModel model.dimensionalModels }
                                    , sendToFrontend clientId (DeliverDimensionalModel (BackendSuccess newDimModel))
                                    )

                                Nothing ->
                                    ( model, sendToFrontend clientId (DeliverDimensionalModel (BackendError ("requested duckDbRef '" ++ refToString duckDbRef ++ "' not found"))) )

                        Nothing ->
                            ( model, sendToFrontend clientId (DeliverDimensionalModel (BackendError ("requested dimensionalModelRef '" ++ dimModelRef ++ "' not found"))) )

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

        Admin_Task_BuildDateDimTable startDate endDate ->
            ( model, send <| BeginTask_BuildDateDim startDate endDate )

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
