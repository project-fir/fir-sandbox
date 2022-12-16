module Pages.Stories.FirLang exposing (Model, Msg, page)

import Array
import ArrayUtil as Array
import Editor exposing (Editor(..))
import EditorModel
import EditorMsg exposing (Context, WrapOption(..))
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Stories.TextEditor exposing (Params)
import Html
import Lambda.Expression exposing (Expr)
import Lambda.Parser exposing (parse)
import Page
import Parser.Advanced as PA
import Request
import Shared
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



-- begin region: constants


textEditorWidth : Int
textEditorWidth =
    800


textEditorPadding : Int
textEditorPadding =
    5


textEditorHeight : Int
textEditorHeight =
    600


textEditorDebugPanelHeight : Int
textEditorDebugPanelHeight =
    250



-- end region: constants


type alias Model =
    { editor : Editor
    , theme : ColorTheme
    }


text : String
text =
    """#
# Fir - a programming language for metric algebra
#
# Note: This demo is designed for keyboard/cursor-based devices, not phones!
#

\\x.x(\\y.y)(\\z.z)

"""


config : EditorModel.Config
config =
    { width = toFloat (textEditorWidth - (2 * textEditorPadding))
    , height = toFloat textEditorHeight
    , fontSize = 16
    , verticalScrollOffset = 3
    , viewMode = EditorModel.Light
    , debugOn = True
    , viewLineNumbersOn = False
    , wrapOption = DontWrap
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    let
        newEditor =
            Editor.initWithContent text config

        -- Editor.initWithContent Text.test1 Load.config
    in
    ( { editor = newEditor
      , theme = shared.selectedTheme
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = MyEditorMsg Editor.EditorMsg


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        MyEditorMsg editorMsg ->
            let
                ( newEditor, cmd ) =
                    Editor.update editorMsg model.editor

                newEditorModel =
                    case newEditor of
                        Editor editorModel ->
                            editorModel

                editorContent : String
                editorContent =
                    -- TODO: This smell non-performant
                    String.join "\n" (Array.toList (Editor.getLines newEditor))

                result : Result (List (PA.DeadEnd Context Problem)) Expr
                result =
                    parse editorContent
            in
            ( { model | editor = newEditor }, Effect.fromCmd <| Cmd.map MyEditorMsg cmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Story - Fir Lang"
    , body = viewElements model
    }


viewElements : Model -> Element Msg
viewElements model =
    el
        [ width fill
        , height fill
        , Background.color model.theme.deadspace
        ]
    <|
        column
            [ width (px textEditorWidth)
            , height (px <| textEditorHeight + textEditorDebugPanelHeight)
            , centerX
            , centerY
            , padding 5
            , Border.width 1
            , Border.color model.theme.secondary
            , Border.rounded 5
            , Background.color model.theme.background
            ]
            [ viewEditor model
            ]


viewEditor : Model -> Element Msg
viewEditor model =
    Editor.view model.editor |> Html.map MyEditorMsg |> E.html
