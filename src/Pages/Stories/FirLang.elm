module Pages.Stories.FirLang exposing (Model, Msg, page)

import Array exposing (Array)
import ArrayUtil as Array
import Debug
import Dict exposing (Dict)
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
import FirLang.Lambda.Eval exposing (eval)
import FirLang.Lambda.Expression as Lambda exposing (Expr, ViewStyle(..))
import FirLang.Lambda.Parser exposing (parse)
import FirLang.Tools.Advanced.Parser as PA
import FirLang.Tools.Problem exposing (Problem)
import Gen.Params.Stories.TextEditor exposing (Params)
import Html
import List.Extra
import Page
import Parser.Advanced exposing (DeadEnd)
import Request
import Shared
import Ui exposing (ColorTheme, TableProps, TableVal(..), firTable)
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
    , evalResult : Maybe String
    , environment : Dict String String
    , theme : ColorTheme
    , debugStr : Maybe String
    , viewStyle : Lambda.ViewStyle
    , cmdLine : String
    }


text : String
text =
    """#
# Fir - a programming language for metric algebra
#
# Note: This demo is designed for keyboard/cursor-based devices, not phones!
#

# feel free to modify the definitions, note how the table in the right nav changes when you type!
:let true = \\x.\\y.x
:let false = \\x.\\y.y
:let and = \\p.\\q.p q p
:let or = \\p.\\q.p p q
:let not = \\p.p (false) true


and true true

"""


config : EditorModel.Config
config =
    { width = toFloat (textEditorWidth - (2 * textEditorPadding))
    , height = toFloat textEditorHeight
    , fontSize = 16
    , verticalScrollOffset = 3
    , viewMode = EditorModel.Light
    , debugOn = False
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
      , evalResult = Nothing
      , debugStr = Nothing
      , environment = Dict.empty
      , viewStyle = Named
      , cmdLine = "x + y"
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = MyEditorMsg Editor.EditorMsg


type ParseLineResult
    = ParseLineOk ( String, String )
    | ParseLineErr String


parseLine : String -> Lambda.ViewStyle -> ParseLineResult
parseLine line viewStyle =
    let
        args_ : List String
        args_ =
            String.split " " line
                |> List.map String.trim

        --|> List.filter (\item -> item /= "")
        cmd =
            List.head args_

        arg =
            List.Extra.getAt 1 args_
                |> Maybe.withDefault ""
    in
    case cmd of
        Just ":let" ->
            case args_ of
                ":let" :: name :: "=" :: rest ->
                    if rest == [] then
                        ParseLineErr "Missing argument: :let foo = BAR"

                    else
                        let
                            data =
                                String.join " " rest |> String.trimRight
                        in
                        ParseLineOk ( name, transformOutput viewStyle data )

                --{ model | environment = Dict.insert name data model.environment } |> withCmd (put <| "added " ++ name ++ " as " ++ transformOutput model.viewStyle data)
                _ ->
                    ParseLineErr "Bad args"

        Just cmd_ ->
            ParseLineErr ("Unknown directive: " ++ cmd_)

        _ ->
            ParseLineErr "Bad input"


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        MyEditorMsg editorMsg ->
            let
                ( newEditor, cmd ) =
                    Editor.update editorMsg model.editor

                -- Step 1, filter out empty line and commented lines
                filteredLines : List String
                filteredLines =
                    List.filterMap
                        (\line ->
                            case String.left 1 line of
                                "" ->
                                    Nothing

                                "#" ->
                                    Nothing

                                _ ->
                                    Just line
                        )
                        (Array.toList (Editor.getLines newEditor))

                -- Step 2, sort into directive and expressions
                sort : List String -> ( List String, List String )
                sort lines_ =
                    let
                        letStatements_ =
                            List.filter (\l -> String.startsWith ":let" l) lines_

                        expressions_ =
                            List.filter (\l -> not (String.startsWith ":let" l)) lines_
                    in
                    ( letStatements_, expressions_ )

                -- unpack step 2
                ( letStatements, expressions ) =
                    ( Tuple.first (sort filteredLines), Tuple.second (sort filteredLines) )

                -- Step 3, parse let statements
                parseResults : List ParseLineResult
                parseResults =
                    List.map (\l -> parseLine l model.viewStyle) letStatements

                envTuples : List ( String, String )
                envTuples =
                    List.filterMap
                        (\plr ->
                            case plr of
                                ParseLineOk ( key, val ) ->
                                    Just ( key, val )

                                ParseLineErr _ ->
                                    Nothing
                        )
                        parseResults

                env =
                    Dict.fromList envTuples

                lines : String
                lines =
                    String.join "\n" expressions

                results : Result (List (DeadEnd FirLang.Tools.Problem.Context Problem)) Expr
                results =
                    parse lines

                evaledResult : String
                evaledResult =
                    evaluate model.viewStyle model.environment lines

                --debugStr =
                --    Just <| Debug.toString evaledResult
            in
            ( { model
                | editor = newEditor
                , evalResult = Just evaledResult

                --, debugStr = debugStr
                , debugStr = Nothing
                , environment = env
              }
            , Effect.fromCmd <| Cmd.map MyEditorMsg cmd
            )


evaluate : Lambda.ViewStyle -> Dict String String -> String -> String
evaluate viewStyle env line =
    eval viewStyle env line



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
            , viewDebugPanel model
            ]


viewDebugPanel : Model -> Element Msg
viewDebugPanel model =
    let
        viewEnvironmentInfoPanel : Dict String String -> Element Msg
        viewEnvironmentInfoPanel env =
            let
                envTableProps : TableProps
                envTableProps =
                    { dataDict =
                        Dict.fromList
                            [ ( "name", List.map (\k -> String_ k) (Dict.keys env) )
                            , ( "val", List.map (\v -> String_ v) (Dict.values env) )
                            ]
                    , tableWidthPx = 100
                    }
            in
            column []
                [ el [ Font.bold ] (E.text "Env:")
                , firTable model envTableProps
                ]

        viewResultsInfoPanel : Maybe String -> Element Msg
        viewResultsInfoPanel evalResult =
            column []
                [ paragraph [ Font.bold ] [ E.text "Eval result:" ]
                , paragraph []
                    [ case evalResult of
                        Nothing ->
                            E.text " "

                        Just r ->
                            E.text r
                    ]
                ]

        viewDebugStringPanel : Element Msg
        viewDebugStringPanel =
            let
                debugString : String
                debugString =
                    case model.debugStr of
                        Nothing ->
                            " "

                        Just str ->
                            str
            in
            column []
                [ paragraph [ Font.bold ] [ E.text "Debug str (local devonly):" ]
                , paragraph [] [ E.text debugString ]
                ]
    in
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
        [ viewEnvironmentInfoPanel model.environment

        --, paragraph [ clipX ] [ E.text debugString ]
        --, paragraph [] [ E.text resultText ]
        , viewResultsInfoPanel model.evalResult

        --, viewDebugStringPanel
        ]


viewEditor : Model -> Element Msg
viewEditor model =
    Editor.view model.editor |> Html.map MyEditorMsg |> E.html



-- begin region: misc. utils


transformOutput : Lambda.ViewStyle -> String -> String
transformOutput viewStyle str =
    case viewStyle of
        Lambda.Raw ->
            str

        Lambda.Pretty ->
            prettify str

        Lambda.Named ->
            prettify str


prettify : String -> String
prettify str =
    String.replace "\\" (String.fromChar 'λ') str



-- end region: misc. utils
