module Pages.Admin exposing (Model, Msg(..), page)

import Bridge exposing (DuckDbCache, DuckDbCache_(..), DuckDbMetaDataCacheEntry, ToBackend(..))
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef)
import DuckDb exposing (DuckDbRef, refToString)
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
            , duckDbCache : DuckDbCache_
            }
    , proxiedServerStatus : Maybe String
    , purgedDataStatus : Maybe String
    , cacheRefreshStatus : Maybe String
    }


init : ( Model, Effect Msg )
init =
    ( { backendModel = Nothing
      , proxiedServerStatus = Nothing
      , purgedDataStatus = Nothing
      , cacheRefreshStatus = Nothing
      }
    , Effect.fromCmd <| sendToBackend Admin_FetchAllBackendData
    )



-- UPDATE


type Msg
    = RefetchBackendData
    | PurgeBackendData
    | UserClickedRefreshBackendCache
    | ProxyServerPingToBackend
    | GotPurgeDataConfirmation String
    | GotCacheRefreshConfirmation String
    | GotProxiedServerPingStatus String
    | GotBackendData
        { sessionIds : List SessionId
        , dimensionalModels : Dict DimensionalModelRef DimensionalModel
        , duckDbCache : DuckDbCache_
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

        PurgeBackendData ->
            ( model, Effect.fromCmd <| sendToBackend Admin_PurgeBackendData )

        GotProxiedServerPingStatus statusStr ->
            ( { model | proxiedServerStatus = Just statusStr }, Effect.none )

        GotPurgeDataConfirmation purgeStr ->
            ( { model | purgedDataStatus = Just purgeStr }, Effect.none )

        UserClickedRefreshBackendCache ->
            ( model, Effect.fromCmd <| sendToBackend Admin_InitiateDuckDbCacheWarmingCycle )

        GotCacheRefreshConfirmation cacheStr ->
            ( { model | cacheRefreshStatus = Just cacheStr }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewQuadrant1_BackendDataManagement : Model -> Element Msg
viewQuadrant1_BackendDataManagement model =
    let
        viewSessionsTable : Element Msg
        viewSessionsTable =
            -- TODO: Unsure what's up with sessions, but it wasn't working well. This isn't a concern for me until I
            --       implement Auth
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

        viewFetchBackendData : Element Msg
        viewFetchBackendData =
            Input.button [ centerX ]
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

        viewProxiedServerStatus : Element Msg
        viewProxiedServerStatus =
            let
                str =
                    case model.proxiedServerStatus of
                        Nothing ->
                            " <-- Click to ping fir-api via Lamdera backend"

                        Just statusStr ->
                            statusStr
            in
            el [ centerX ] <| E.text str

        viewPingButton : Element Msg
        viewPingButton =
            Input.button [ centerX ]
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

        viewPurgeButton : Element Msg
        viewPurgeButton =
            Input.button [ centerX ]
                { onPress = Just PurgeBackendData
                , label =
                    el
                        [ Border.width 1
                        , Border.color Palette.darkishGrey
                        , Background.color Palette.orange_error_alert
                        , Border.rounded 3
                        , padding 5
                        ]
                        (E.text "PURGE!")
                }

        viewCacheRefreshButton : Element Msg
        viewCacheRefreshButton =
            Input.button [ centerX ]
                { onPress = Just UserClickedRefreshBackendCache
                , label =
                    el
                        [ Border.width 1
                        , Border.color Palette.darkishGrey
                        , Background.color Palette.lightGrey
                        , Border.rounded 3
                        , padding 5
                        ]
                        (E.text "Refresh DuckDb Cache")
                }

        viewCacheRefreshStatus : Element Msg
        viewCacheRefreshStatus =
            let
                str =
                    case model.cacheRefreshStatus of
                        Nothing ->
                            "<-- Click to refresh Lamdera Backend of DuckDb meta data"

                        Just statusStr ->
                            statusStr
            in
            el [ centerX ] <| E.text str

        viewPurgeStatus : Element Msg
        viewPurgeStatus =
            let
                str =
                    case model.purgedDataStatus of
                        Nothing ->
                            "🚨🚨🚨 <-- Click to PURGE ALL backend data 🚨🚨🚨"

                        Just statusStr ->
                            "⚠️" ++ statusStr ++ "⚠️"
            in
            el [ centerX ] <| E.text str
    in
    column
        [ width fill
        , height fill
        , padding 10
        , spacing 10
        ]
        [ row [ spacing 10 ] [ viewFetchBackendData, E.text "<-- click to refresh this page's view of Backend data" ]
        , row [ spacing 10 ] [ viewPingButton, viewProxiedServerStatus ]
        , row [ spacing 10 ] [ viewCacheRefreshButton, viewCacheRefreshStatus ]
        , row [ spacing 10 ] [ viewPurgeButton, viewPurgeStatus ]
        , row [ spacing 10 ] [ E.text "TODO: sessions viewer" ]
        ]


viewPanelQuadrant2_DimensionalModelAndDuckDbCache : Model -> Element Msg
viewPanelQuadrant2_DimensionalModelAndDuckDbCache model =
    let
        viewDimensionalModelsTable : Element Msg
        viewDimensionalModelsTable =
            let
                data :
                    List
                        { numSelectedDbRefs : Int
                        , numTableInfos : Int
                        , ref : DimensionalModelRef
                        }
                data =
                    case model.backendModel of
                        Nothing ->
                            []

                        Just model_ ->
                            List.map
                                (\dimModel ->
                                    { numSelectedDbRefs = List.length dimModel.selectedDbRefs
                                    , numTableInfos = Dict.size dimModel.tableInfos
                                    , ref = dimModel.ref
                                    }
                                )
                                (Dict.values model_.dimensionalModels)
            in
            E.table
                [ centerX
                , padding 5
                , width (px 600)
                ]
                { data = data
                , columns =
                    [ { header =
                            el
                                [ Border.color Palette.black
                                , Border.widthEach { top = 1, right = 1, left = 1, bottom = 3 }
                                , padding 3
                                , Background.color Palette.lightGrey
                                ]
                            <|
                                el [ Font.bold ] <|
                                    E.text "ref"
                      , width = px 80
                      , view =
                            \dimModel ->
                                el
                                    [ Border.color Palette.black
                                    , Border.width 1
                                    , padding 3
                                    ]
                                    (el [ Font.size 12 ] <| E.text dimModel.ref)
                      }
                    , { header =
                            el
                                [ Border.color Palette.black
                                , Border.widthEach { top = 1, right = 1, left = 1, bottom = 3 }
                                , padding 3
                                , Background.color Palette.lightGrey
                                ]
                            <|
                                el [ Font.bold ] <|
                                    E.text "num_selected_refs"
                      , width = px 120
                      , view =
                            \data_ ->
                                el
                                    [ Border.color Palette.black
                                    , Border.width 1
                                    , padding 3
                                    ]
                                    (el [ Font.size 12 ] <| E.text (String.fromInt data_.numSelectedDbRefs))
                      }
                    , { header =
                            el
                                [ Border.color Palette.black
                                , Border.widthEach { top = 1, right = 1, left = 1, bottom = 3 }
                                , padding 3
                                , Background.color Palette.lightGrey
                                ]
                            <|
                                el [ Font.bold ] <|
                                    E.text "num_table_infos"
                      , width = px 120
                      , view =
                            \data_ ->
                                el
                                    [ Border.color Palette.black
                                    , Border.width 1
                                    , padding 3
                                    ]
                                    (el [ Font.size 12 ] <| E.text (String.fromInt data_.numTableInfos))
                      }
                    ]
                }

        viewDuckDbCacheTable : Element Msg
        viewDuckDbCacheTable =
            let
                viewTableWithSummary : String -> List DuckDbRef -> Element Msg
                viewTableWithSummary summary cachedRefs =
                    column [ centerX, spacing 5 ]
                        [ E.text summary
                        , E.table
                            [ centerX
                            , width (px 600)
                            ]
                            { data = cachedRefs
                            , columns =
                                [ { header =
                                        el
                                            [ Border.color Palette.black
                                            , Border.widthEach { top = 1, right = 1, left = 1, bottom = 3 }
                                            , padding 3
                                            , Background.color Palette.lightGrey
                                            ]
                                        <|
                                            el [ Font.bold ] <|
                                                E.text "ref"
                                  , width = px 180
                                  , view =
                                        \ref ->
                                            el
                                                [ Border.color Palette.black
                                                , Border.width 1
                                                , padding 3
                                                ]
                                                (el [ Font.size 12 ] <| E.text (refToString ref))
                                  }
                                ]
                            }
                        ]
            in
            case model.backendModel of
                Nothing ->
                    viewTableWithSummary "Please refresh page to view latest data" []

                Just model_ ->
                    case model_.duckDbCache of
                        Cold duckDbCache ->
                            viewTableWithSummary "Cache is COLD" duckDbCache.refs

                        WarmingCycleInitiated duckDbCache ->
                            viewTableWithSummary "Cache is WARMING" duckDbCache.refs

                        Warming duckDbCache _ _ ->
                            viewTableWithSummary "Cache is WARMING" duckDbCache.refs

                        Hot duckDbCache ->
                            viewTableWithSummary "Cache is HOT" duckDbCache.refs
    in
    column
        [ width fill
        , height fill
        , padding 10
        , spacing 10
        ]
        [ column [ padding 5, spacing 5, width fill, Border.width 1, Border.color Palette.black ]
            [ E.text "Dimensional models stored in Lamdera backend:"
            , viewDimensionalModelsTable
            ]
        , column [ padding 5, spacing 5, width fill, Border.width 1, Border.color Palette.black ]
            [ E.text "DuckDbRefs cached in Lamdera backend:"
            , viewDuckDbCacheTable
            ]
        ]


viewElements : Model -> Element Msg
viewElements model =
    column
        [ width fill
        , height fill
        , centerX
        , centerY
        , Border.width 2
        , Border.rounded 5
        , Border.color Palette.black
        , Background.color Palette.lightGrey
        , padding 10
        , spacing 10
        ]
        [ el [ width fill, Font.size 18, paddingXY 5 0 ] (E.text "One day I'll need to lock this down, but for now, enjoy the admin rights!")
        , row
            [ width fill
            , height (fillPortion 5)
            , spacing 10
            ]
            [ el
                [ width (fillPortion 5)
                , height fill
                , Border.width 1
                , Border.rounded 3
                , Border.color Palette.darkishGrey
                , Background.color Palette.white
                ]
                (viewQuadrant1_BackendDataManagement model)
            , el
                [ width (fillPortion 5)
                , height fill
                , Border.width 1
                , Border.rounded 3
                , Background.color Palette.white
                ]
                (viewPanelQuadrant2_DimensionalModelAndDuckDbCache model)
            ]
        , row
            [ width fill
            , height (fillPortion 5)
            , spacing 10
            ]
            [ el
                [ width (fillPortion 5)
                , height fill
                , Border.width 1
                , Border.rounded 3
                , Border.color Palette.darkishGrey
                ]
                (E.text "Q III - Quadrant reserved for future use")
            , el
                [ width (fillPortion 5)
                , height fill
                , Border.width 1
                , Border.rounded 3
                , Border.color Palette.darkishGrey
                ]
                (E.text "Q IV - Quadrant reserved for future use")
            ]
        ]



--[ viewFetchBackendData
--, el [ centerX ] (E.text "Session ids:")
--, viewSessionsTable
--, el [ centerX ] (E.text "Dimensional models:")
--, viewDimensionalModelsTable
--, viewPingButton
--, viewProxiedServerStatus
--, viewPurgeButton
--, viewPurgeStatus
--, viewCacheRefreshButton
--, viewCacheRefreshStatus
--]


view : Model -> View Msg
view model =
    { title = "Admin"
    , body = [ viewElements model ]
    }
