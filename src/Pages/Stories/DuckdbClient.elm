module Pages.Stories.DuckdbClient exposing (Model, Msg, page)

import Browser.Dom
import Browser.Events as BE
import Editor exposing (Editor, resize)
import EditorModel
import EditorMsg exposing (WrapOption(..))
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import FirApi exposing (DuckDbRef, DuckDbRefsResponse, PingResponse, fetchDuckDbTableRefs, pingServer)
import Gen.Params.Stories.DuckdbClient exposing (Params)
import Html
import Http
import Page
import RemoteData exposing (RemoteData(..))
import Request
import Shared
import Task
import Time exposing (Posix)
import Ui exposing (ButtonProps, ColorTheme, button)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT
-- MODEL


type alias Model =
    { editor : Editor
    , theme : ColorTheme
    , viewStatus : ViewStatus
    , firApiStatus : FirApiStatus
    , duckDbRefs : RemoteData Http.Error (List DuckDbRef)
    }



-- begin region: fir-api-status logic


scaleFromZeroPeriodMs =
    1000


cyclesUntilExhaustion =
    -- NB: There are 60,000 ms in a minute, poll for 30 seconds before exhaustion
    round (3.0e4 / scaleFromZeroPeriodMs)


readyPeriodMs : Float
readyPeriodMs =
    -- when we know FirApi status is green, poll every 10 seconds, to keep it awake
    1.0e4


type
    FirApiStatus
    -- Accepts period between polls, in ms, and number of attempts thus far
    = AwaitingScaleFromZero Float Int
      -- Accepts period between polls, when ready
    | ApiReady Float
    | ExhaustedWaitingPeriod



-- end region: fir-api-status logic


type ViewStatus
    = AwaitingViewportInfo
    | Ready LayoutInfo


type alias LayoutInfo =
    { textPanelWidthPx : Float
    , textPanelHeightPx : Float
    , navWidthPct : Int
    , dataTableHeightPct : Int
    }


computeLayoutInfo : Browser.Dom.Viewport -> LayoutInfo
computeLayoutInfo viewPort =
    let
        navWidthPct =
            20

        dataTableHeightPct =
            40
    in
    { textPanelWidthPx = viewPort.viewport.width * ((100 - navWidthPct) / 100)
    , textPanelHeightPx = viewPort.viewport.height * ((100 - dataTableHeightPct) / 100)
    , navWidthPct = navWidthPct
    , dataTableHeightPct = dataTableHeightPct
    }


text : String
text =
    """
select * from finnhub.company_news
"""


defaultEditorConfig : EditorModel.Config
defaultEditorConfig =
    -- NB: width and height values are placeholders until screen size is returned to our Model,
    --     we don't render the editor until that happens, so the particular values here shouldn't matter.
    { width = 600
    , height = 500
    , fontSize = 16
    , verticalScrollOffset = 3
    , viewMode = EditorModel.Dark
    , debugOn = False

    -- TODO: viewing line numbers results in strange UI behavior, debug why
    , viewLineNumbersOn = False
    , wrapOption = DontWrap
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    let
        newEditor : Editor
        newEditor =
            Editor.initWithContent text defaultEditorConfig
    in
    ( { editor = newEditor
      , theme = shared.selectedTheme
      , viewStatus = AwaitingViewportInfo
      , firApiStatus = AwaitingScaleFromZero scaleFromZeroPeriodMs 1
      , duckDbRefs = NotAsked
      }
    , Effect.fromCmd (Task.perform GotViewport Browser.Dom.getViewport)
    )



-- UPDATE


type Msg
    = MyEditorMsg Editor.EditorMsg
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | Tick_PingFirApi Posix
    | Got_PingResponse Int (Result Http.Error PingResponse)
    | Got_DuckDbRefsResponse (Result Http.Error DuckDbRefsResponse)
    | UserClickedQueryButton


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Got_DuckDbRefsResponse resp ->
            case resp of
                Ok resp_ ->
                    ( { model | duckDbRefs = Success resp_.refs }, Effect.none )

                Err error ->
                    ( { model | duckDbRefs = Failure error }, Effect.none )

        UserClickedQueryButton ->
            ( model, Effect.none )

        Got_PingResponse count err ->
            case err of
                Ok _ ->
                    let
                        effect =
                            case model.duckDbRefs of
                                Success _ ->
                                    -- this may occur if backend connection was lost for a sec, but refs remain in
                                    -- memory
                                    Effect.none

                                _ ->
                                    -- we receive a 200 from the server and don't have refs in memory, go fetch them
                                    Effect.fromCmd (fetchDuckDbTableRefs Got_DuckDbRefsResponse)
                    in
                    -- Change FirApi status to green, fetch duckdb refs if we don't already have them in memory
                    ( { model | firApiStatus = ApiReady readyPeriodMs }, effect )

                Err error ->
                    case count > cyclesUntilExhaustion of
                        True ->
                            -- exhausted attempt, update model
                            ( { model | firApiStatus = ExhaustedWaitingPeriod }, Effect.none )

                        False ->
                            -- noop, continue
                            ( model, Effect.none )

        Tick_PingFirApi _ ->
            case model.firApiStatus of
                AwaitingScaleFromZero ms attemptCount ->
                    -- we are awaiting scaling, and assuming it'll come up
                    ( { model | firApiStatus = AwaitingScaleFromZero ms (attemptCount + 1) }
                    , Effect.fromCmd (pingServer (Just <| scaleFromZeroPeriodMs - 150) (Got_PingResponse attemptCount))
                    )

                ApiReady int ->
                    -- we have already reported api is green, verify
                    ( model, Effect.none )

                ExhaustedWaitingPeriod ->
                    -- noop
                    ( model, Effect.none )

        GotViewport viewPort ->
            let
                layoutInfo : LayoutInfo
                layoutInfo =
                    computeLayoutInfo viewPort

                newEditor =
                    -- NB: We subtract 2 pixels from width, to allow for border of width 1
                    --     We subtract 75 pixels form height, to allow for editor status panel, which extends beyond
                    --     the editors nominal height.
                    resize (layoutInfo.textPanelWidthPx - 2) (layoutInfo.textPanelHeightPx - 75) model.editor
            in
            ( { model
                | viewStatus = Ready layoutInfo
                , editor = newEditor
              }
            , Effect.none
            )

        GotResizeEvent _ _ ->
            ( model, Effect.fromCmd (Task.perform GotViewport Browser.Dom.getViewport) )

        MyEditorMsg editorMsg ->
            let
                ( newEditor, cmd ) =
                    Editor.update editorMsg model.editor
            in
            ( { model | editor = newEditor }, Effect.fromCmd <| Cmd.map MyEditorMsg cmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        firApiPollPeriod =
            case model.firApiStatus of
                AwaitingScaleFromZero ms _ ->
                    ms

                ApiReady ms ->
                    ms

                ExhaustedWaitingPeriod ->
                    -- An unfeasibly long period, to stop polling (until user refreshes)
                    1.0e10
    in
    Sub.batch
        [ BE.onResize GotResizeEvent
        , Time.every firApiPollPeriod Tick_PingFirApi
        ]



-- VIEW


view : Model -> View Msg
view model =
    { title = "Story | DuckDB Client"
    , body =
        case model.viewStatus of
            AwaitingViewportInfo ->
                E.none

            Ready layoutInfo ->
                viewElements model layoutInfo
    }


viewToolbar : Model -> Element Msg
viewToolbar model =
    let
        buttonProps : ButtonProps Msg
        buttonProps =
            { onClick = Just UserClickedQueryButton
            , displayText = "Query"
            }
    in
    el
        [ width fill
        , height (px 40)
        , Border.color model.theme.debugAlert
        , Background.color model.theme.background
        ]
        (el [ centerX, centerY ] <| button model buttonProps)


viewElements : Model -> LayoutInfo -> Element Msg
viewElements model layoutInfo =
    el
        [ width fill
        , height fill
        , Background.color model.theme.deadspace
        , padding 3
        , Font.size 16
        ]
    <|
        column
            [ centerX
            , centerY
            , padding 5
            , spacing 5
            , Background.color model.theme.deadspace
            , width fill
            , height fill
            ]
            [ row
                [ width fill
                , height (fillPortion (100 - layoutInfo.dataTableHeightPct))
                , spacing 5
                ]
                [ el
                    [ width (fillPortion layoutInfo.navWidthPct)
                    , height fill
                    , Border.color model.theme.secondary
                    , Border.width 1
                    , Border.rounded 3
                    ]
                    (viewNavPanel model)
                , column
                    [ width (fillPortion (100 - layoutInfo.navWidthPct))
                    , height fill
                    , Border.color model.theme.secondary
                    , Border.width 1
                    , Border.rounded 3
                    ]
                    [ viewEditorPanel model
                    , viewToolbar model
                    ]
                ]
            , el
                [ width fill
                , height (fillPortion layoutInfo.dataTableHeightPct)
                , Border.color model.theme.secondary
                , Border.width 1
                , Border.rounded 3
                ]
                (viewDataTable model)
            ]


viewEditorPanel : Model -> Element Msg
viewEditorPanel model =
    let
        viewEditor : Element Msg
        viewEditor =
            Editor.view model.editor |> Html.map MyEditorMsg |> E.html
    in
    el
        [ width fill
        , height fill
        , centerX
        , centerY
        ]
        viewEditor


viewFirApiStatus : ColorTheme -> FirApiStatus -> Element Msg
viewFirApiStatus theme status =
    let
        panelEl =
            el [ width fill, centerX ]
    in
    case status of
        AwaitingScaleFromZero _ attemptCount ->
            panelEl (E.text <| "Polling server, attempt " ++ String.fromInt attemptCount)

        ApiReady _ ->
            panelEl (E.text "Fir API ready! ")

        ExhaustedWaitingPeriod ->
            panelEl
                (paragraph
                    [ Background.color theme.debugAlert
                    , Font.bold
                    , padding 2
                    ]
                    [ E.text "All attempts to reach Fir API have been exhausted, this likely means something server-side is broken!" ]
                )


viewNavPanel : Model -> Element Msg
viewNavPanel model =
    let
        navRefElements =
            case model.duckDbRefs of
                NotAsked ->
                    E.none

                Loading ->
                    E.none

                Failure e ->
                    let
                        partialElements =
                            el [ Background.color model.theme.debugAlert, Font.bold ]
                    in
                    case e of
                        Http.BadUrl string ->
                            partialElements (E.text string)

                        Http.Timeout ->
                            partialElements (E.text "Request timed out.")

                        Http.NetworkError ->
                            partialElements (E.text "Network error")

                        Http.BadStatus status ->
                            partialElements (E.text <| "Bad status: " ++ String.fromInt status)

                        Http.BadBody body ->
                            partialElements (E.text <| "Bad body: " ++ body)

                Success refs ->
                    let
                        viewRef : DuckDbRef -> Element Msg
                        viewRef ref =
                            el
                                [ width fill
                                ]
                                (E.text <| ref.schemaName ++ "." ++ ref.tableName)
                    in
                    column
                        [ width fill
                        , height fill
                        , spacing 5
                        , clipX
                        , scrollbarX
                        ]
                        (List.map (\ref -> viewRef ref) refs)
    in
    column
        [ width fill
        , height fill
        , centerX
        , centerY
        , Background.color model.theme.background
        ]
        [ viewFirApiStatus model.theme model.firApiStatus
        , paragraph [] [ E.text "TODO: Tree nav view goes here, below is a placeholder implementation" ]
        , navRefElements
        ]


viewDataTable : Model -> Element Msg
viewDataTable model =
    el
        [ width fill
        , height fill
        , Background.color model.theme.background
        ]
        (el [ centerX, centerY ] <| E.text "Data table goes here")


viewDebugPanel : Model -> Element Msg
viewDebugPanel model =
    column
        [ width (px 450)
        , height fill
        , padding 5
        , Border.width 1
        , Border.color model.theme.secondary
        , Border.rounded 3
        , clipY
        , scrollbarY
        , clipX
        , scrollbarX
        , spacing 5
        ]
        [ E.text "TODO: Yes, I do want a debug panel here. This page will perform simple query parsing to supply duckdb fallback refs, that'll need debugging!"
        ]
