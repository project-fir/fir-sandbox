module Backend exposing (..)

import Bridge exposing (ToBackend(..))
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)
import Graph
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Types exposing (BackendModel, BackendMsg(..), FrontendMsg(..), Session, ToFrontend(..))


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
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoopBackend ->
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
