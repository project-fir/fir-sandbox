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
import FirLang.Lambda.Expression exposing (Expr)
import FirLang.Lambda.Parser exposing (parse)
import FirLang.Tools.Advanced.Parser as PA
import FirLang.Tools.Problem exposing (Problem)
import Gen.Params.Stories.TextEditor exposing (Params)
import Html
import Page
import Parser.Advanced exposing (DeadEnd)
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


type alias TextEditorResult =
    Result (List (DeadEnd FirLang.Tools.Problem.Context Problem)) Expr


type alias Model =
    { editor : Editor
    , result : Maybe TextEditorResult
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
    in
    ( { editor = newEditor
      , theme = shared.selectedTheme
      , result = Nothing
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

                editorContent : String
                editorContent =
                    -- TODO: This smell non-performant
                    String.join "\n" (Array.toList (Editor.getLines newEditor))

                result : Result (List (DeadEnd FirLang.Tools.Problem.Context Problem)) Expr
                result =
                    parse editorContent
            in
            ( { model
                | editor = newEditor
                , result = Just result
              }
            , Effect.fromCmd <| Cmd.map MyEditorMsg cmd
            )



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
        row
            [ centerX
            , centerY
            , padding 5
            , Border.width 1
            , Border.color model.theme.secondary
            , Border.rounded 5
            , spacing 5
            , Background.color model.theme.background
            ]
            [ el
                [ width (px textEditorWidth)
                , height (px <| textEditorHeight + textEditorDebugPanelHeight)
                ]
              <|
                viewEditor model
            , viewResultPanel model
            ]


viewResultPanel : Model -> Element Msg
viewResultPanel model =
    el
        [ width (px 200)
        , height fill
        , padding 5
        , Border.width 1
        , Border.color model.theme.secondary
        , Border.rounded 3
        ]
        (E.text "result")


viewEditor : Model -> Element Msg
viewEditor model =
    Editor.view model.editor |> Html.map MyEditorMsg |> E.html
