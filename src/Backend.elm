module Backend exposing (..)

import Bridge exposing (BackendErrorMessage(..), DeliveryEnvelope(..), ToBackend(..))
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)
import DuckDb exposing (DuckDbRef, DuckDbRefString, fetchDuckDbTableRefs, pingServer, queryDuckDbMeta, refToString)
import Graph
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import RemoteData exposing (RemoteData(..))
import Task
import Types exposing (BackendModel, BackendMsg(..), DuckDbCache, FrontendMsg(..), Session, ToFrontend(..))
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
      , duckDbCache = Nothing
      , partialDuckDbCacheInProgress = Nothing
      , partialRemainingRefs = Nothing
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoopBackend ->
            ( model, Cmd.none )

        PingServer ->
            ( { model | serverPingStatus = Loading }, pingServer GotPingResponse )

        GotPingResponse result ->
            case result of
                Ok value ->
                    ( { model | serverPingStatus = Success value }, broadcast (Admin_DeliverServerStatus "OK") )

                Err error ->
                    ( { model | serverPingStatus = Failure error }, broadcast (Admin_DeliverServerStatus "ERROR!") )

        BeginDuckDbCacheRefresh ->
            ( model, fetchDuckDbTableRefs GotDuckDbRefsResponse )

        GotDuckDbRefsResponse response ->
            case response of
                Ok refs ->
                    ( { model | partialRemainingRefs = Just refs.refs }, send ContinueDuckDbCacheRefresh )

                Err err ->
                    ( model, Cmd.none )

        ContinueDuckDbCacheRefresh ->
            let
                ( newModel, nextCmd ) =
                    case model.partialRemainingRefs of
                        Nothing ->
                            ( model, Cmd.none )

                        Just refs ->
                            case refs of
                                [] ->
                                    ( { model | partialRemainingRefs = Nothing }, send CompleteDuckDbCacheRefresh )

                                r :: rs ->
                                    let
                                        queryStr : String
                                        queryStr =
                                            "select * from " ++ refToString r
                                    in
                                    ( { model | partialRemainingRefs = Just rs }, queryDuckDbMeta queryStr True [ r ] GotDuckDbMetaDataResponse )
            in
            ( newModel, nextCmd )

        CompleteDuckDbCacheRefresh ->
            ( { model
                | duckDbCache = model.partialDuckDbCacheInProgress
                , partialDuckDbCacheInProgress = Nothing
                , partialRemainingRefs = Nothing
              }
            , broadcast (Admin_DeliverCacheRefreshConfirmation "Cache refresh complete!")
            )

        GotDuckDbMetaDataResponse result ->
            case result of
                Ok metaResponse ->
                    let
                        ref : DuckDbRef
                        ref =
                            case metaResponse.refs of
                                [] ->
                                    { tableName = "ERROR", schemaName = "ERROR!" }

                                r :: _ ->
                                    r

                        updatedCache : DuckDbCache
                        updatedCache =
                            case model.partialDuckDbCacheInProgress of
                                Nothing ->
                                    { refs = [] -- This shouldn't happen, but makes me think I want to refactor this
                                    , metaData =
                                        Dict.fromList
                                            [ ( refToString ref
                                              , { ref = ref
                                                , columnDescriptions = metaResponse.columnDescriptions
                                                }
                                              )
                                            ]
                                    }

                                Just duckDbCache ->
                                    -- TODO: Update response
                                    duckDbCache
                    in
                    ( { model | duckDbCache = Just updatedCache }, send ContinueDuckDbCacheRefresh )

                Err err ->
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
                                , tableInfos = Dict.empty
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
                    }
                )
            )

        Admin_PingServer ->
            ( model, send PingServer )

        Admin_RefreshDuckDbMetaData ->
            ( model, send BeginDuckDbCacheRefresh )

        Admin_PurgeBackendData ->
            let
                newModel =
                    { sessions = model.sessions -- keep active sessions, otherwise you may need to re-auth etc. That'd be weird
                    , dimensionalModels = Dict.empty
                    , serverPingStatus = NotAsked -- in theory there's a race condition here if a server ping is in progress, not worth doing it right
                    , duckDbCache = Nothing
                    , partialDuckDbCacheInProgress = Nothing
                    , partialRemainingRefs = Nothing
                    }
            in
            ( newModel, sendToFrontend clientId (Admin_DeliverPurgeConfirmation "data has been purged") )

        Kimball_FetchDuckDbRefs ->
            case model.duckDbCache of
                Nothing ->
                    ( model, sendToFrontend clientId (DeliverDuckDbRefs (BackendError (PlainMessage "duckdb refs cache requested, but doesn't exist"))) )

                Just duckDbCache ->
                    ( model, sendToFrontend clientId (DeliverDuckDbRefs (BackendSuccess duckDbCache.refs)) )
