module Pages.Admin exposing (Model, Msg(..), page)

--import Types exposing (Session)

import Bridge exposing (ToBackend(..))
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Admin exposing (Params)
import Lamdera exposing (SessionId, sendToBackend)
import Page
import Palette
import Request
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { backendModel :
        Maybe
            { sessionIds : List SessionId
            , dimensionalModels : Dict DimensionalModelRef DimensionalModel
            }
    , proxiedServerStatus : Maybe String
    }


init : ( Model, Effect Msg )
init =
    ( { backendModel = Nothing
      , proxiedServerStatus = Nothing
      }
    , Effect.fromCmd <| sendToBackend Admin_FetchAllBackendData
    )



-- UPDATE


type Msg
    = RefetchBackendData
    | ProxyServerPingToBackend
    | GotProxiedServerPingStatus String
    | GotBackendData
        { sessionIds : List SessionId
        , dimensionalModels : Dict DimensionalModelRef DimensionalModel
        }


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        RefetchBackendData ->
            ( model, Effect.fromCmd <| sendToBackend Admin_FetchAllBackendData )

        GotBackendData backendModel ->
            ( { model | backendModel = Just backendModel }, Effect.none )

        ProxyServerPingToBackend ->
            ( model, Effect.fromCmd <| sendToBackend Admin_PingServer )

        GotProxiedServerPingStatus statusStr ->
            ( { model | proxiedServerStatus = Just statusStr }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewElements : Model -> Element Msg
viewElements model =
    let
        viewSessionsTable : Element Msg
        viewSessionsTable =
            let
                data =
                    case model.backendModel of
                        Nothing ->
                            []

                        Just model_ ->
                            model_.sessionIds
            in
            E.table
                [ centerX
                , padding 5
                , width (px 600)
                ]
                { data = data
                , columns =
                    [ { header = el [ Border.color Palette.black, Border.width 1 ] <| E.text "session id"
                      , width = px 150
                      , view = \sid -> el [] (E.text sid)
                      }
                    ]
                }

        viewDimensionalModelsTable : Element Msg
        viewDimensionalModelsTable =
            let
                data : List DimensionalModel
                data =
                    case model.backendModel of
                        Nothing ->
                            []

                        Just model_ ->
                            Dict.values model_.dimensionalModels
            in
            E.table
                [ centerX
                , padding 5
                , width (px 600)
                ]
                { data = data
                , columns =
                    [ { header = el [ Border.color Palette.black, Border.width 1 ] <| E.text "ref"
                      , width = px 80
                      , view = \dimModel -> el [] (E.text dimModel.ref)
                      }
                    ]
                }

        viewProxiedServerStatus : Element Msg
        viewProxiedServerStatus =
            let
                str =
                    case model.proxiedServerStatus of
                        Nothing ->
                            "^click above to ping"

                        Just statusStr ->
                            statusStr
            in
            el [ centerX ] <| E.text str
    in
    column
        [ width fill
        , height fill
        , centerX
        , spacing 10
        ]
        [ Input.button [ centerX ]
            { onPress = Just RefetchBackendData
            , label =
                el
                    [ Border.width 1
                    , Border.color Palette.darkishGrey
                    , Background.color Palette.lightGrey
                    , Border.rounded 3
                    , padding 5
                    ]
                    (E.text "Fetch!")
            }
        , el [ centerX ] (E.text "Session ids:")
        , viewSessionsTable
        , el [ centerX ] (E.text "Dimensional models:")
        , viewDimensionalModelsTable
        , Input.button [ centerX ]
            { onPress = Just ProxyServerPingToBackend
            , label =
                el
                    [ Border.width 1
                    , Border.color Palette.darkishGrey
                    , Background.color Palette.lightGrey
                    , Border.rounded 3
                    , padding 5
                    ]
                    (E.text "Proxy ping")
            }
        , viewProxiedServerStatus
        ]


view : Model -> View Msg
view model =
    { title = "Admin"
    , body = [ viewElements model ]
    }
