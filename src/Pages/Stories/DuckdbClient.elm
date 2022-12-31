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
import Gen.Params.Stories.TextEditor exposing (Params)
import Html
import Page
import Request
import Shared
import Task
import Ui exposing (ColorTheme)
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
    }


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
Hello, is it me you're looking for!?
"""


config : EditorModel.Config
config =
    { width = 600 -- 1200
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
            Editor.initWithContent text config
    in
    ( { editor = newEditor
      , theme = shared.selectedTheme
      , viewStatus = AwaitingViewportInfo
      }
    , Effect.fromCmd (Task.perform GotViewport Browser.Dom.getViewport)
    )



-- UPDATE


type Msg
    = MyEditorMsg Editor.EditorMsg
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
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
    Sub.batch [ BE.onResize GotResizeEvent ]



-- VIEW


view : Model -> View Msg
view model =
    { title = "Story | Text Editor"
    , body =
        case model.viewStatus of
            AwaitingViewportInfo ->
                E.none

            Ready layoutInfo ->
                viewElements model layoutInfo
    }


viewElements : Model -> LayoutInfo -> Element Msg
viewElements model layoutInfo =
    el
        [ width fill
        , height fill
        , Background.color model.theme.deadspace
        , padding 3
        ]
    <|
        column
            [ centerX
            , centerY
            , padding 5
            , spacing 5
            , Background.color model.theme.background
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
                    (viewNav model)
                , el
                    [ width (fillPortion (100 - layoutInfo.navWidthPct))
                    , height fill
                    , Border.color model.theme.secondary
                    , Border.width 1
                    , Border.rounded 3
                    ]
                    (viewEditorPanel model)
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


viewNav : Model -> Element Msg
viewNav model =
    el [ width fill, height fill, centerX, centerY ] (E.text "Nav goes here")


viewDataTable : Model -> Element Msg
viewDataTable model =
    el [ width fill, height fill, centerX, centerY ] (E.text "Data table goes here")


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
        [ E.text "TODO: Do I want a debug panel in this story???"
        ]
