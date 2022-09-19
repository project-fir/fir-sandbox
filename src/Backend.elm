module Backend exposing (..)

import Bridge exposing (ToBackend(..))
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)
import Lamdera exposing (ClientId, SessionId, sendToFrontend)
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
                                { selectedTables = []
                                , renderInfos = Dict.empty
                                }
                                model.dimensionalModels

                        newRefs : List DimensionalModelRef
                        newRefs =
                            Dict.keys newDimModels
                    in
                    ( { model | dimensionalModels = newDimModels }, sendToFrontend clientId (DeliverDimensionalModelRefs newRefs) )
