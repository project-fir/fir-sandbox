module Pages.Stories.FirLang exposing (Model, Msg, page)

import Editor exposing (Editor)
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
-- MODEL


type alias Model =
    { editor : Editor
    }


text : String
text =
    "Hello, is it me you're looking for!?"


config : EditorModel.Config
config =
    { width = 800 -- 1200
    , height = 1200
    , fontSize = 16
    , verticalScrollOffset = 3
    , viewMode = EditorModel.Dark
    , debugOn = False
    , viewLineNumbersOn = False
    , wrapOption = DontWrap
    }


init : ( Model, Effect Msg )
init =
    let
        newEditor =
            Editor.initWithContent text config

        -- Editor.initWithContent Text.test1 Load.config
    in
    ( { editor = newEditor }
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
    , body = viewEditor model
    }


viewElements : Model -> Element Msg
viewElements model =
    E.none


viewEditor : Model -> Element Msg
viewEditor model =
    Editor.view model.editor |> Html.map MyEditorMsg |> E.html
