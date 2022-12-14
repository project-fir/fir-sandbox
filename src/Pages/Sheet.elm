module Pages.Sheet exposing (Model, Msg, page)

import Array as A
import Array2D exposing (Array2D, ColIx, RowIx, colCount, fromListOfLists, getCol, rowCount, setValueAt)
import Browser.Dom
import Browser.Events as Events
import Config exposing (apiHost)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import File exposing (File)
import File.Select as Select
import FirApi exposing (DuckDbColumn(..), DuckDbMetaResponse, DuckDbQueryResponse, DuckDbRef, DuckDbRefsResponse, fetchDuckDbTableRefs, queryDuckDb, refEquals, refToString, uploadFile)
import Gen.Params.Sheet exposing (Params)
import Html as H
import Html.Attributes as HA
import Http exposing (Error(..))
import ISO8601 as Iso
import Json.Decode as JD
import List.Extra as LE
import Page
import RemoteData exposing (RemoteData(..), WebData)
import Request
import Set exposing (Set)
import Shared
import SheetModel exposing (Cell, CellCoords, CellElement(..), ColumnLabel, RawPromptString, SheetEnvelope, array2DToSheet, elementAt)
import String exposing (fromInt)
import Task
import Time exposing (Posix)
import Ui exposing (theme)
import Utils exposing (KeyCode, keyDecoder, send)
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


type PromptMode
    = Idle
    | PromptInProgress String


type ReplayState
    = Paused
    | Playing


type alias TimelineState =
    { currentFrame : Int
    , replayState : ReplayState
    }


type
    RenderStatus
    -- Since a lot of stuff is being rendered, initialize model to be Awaiting, and start the task of fetching
    -- browser viewport size. Once received, this will be flipped to Ready, which then renders
    -- This avoids the "double paint" problem on initial page loads (first paint assumes default screen size, followed
    -- by a correct paint)
    = AwaitingDomInfo
    | Ready


type alias Model =
    { sheet : SheetEnvelope
    , sheetMode : DataInspectMode
    , keysDown : Set KeyCode
    , selectedCell : Maybe Cell
    , promptMode : PromptMode
    , submissionHistory : List RawPrompt
    , timeline : A.Array Timeline
    , uiMode : UiMode
    , duckDbResponse : WebData DuckDbQueryResponse
    , duckDbMetaResponse : WebData DuckDbMetaResponse
    , duckDbTableRefs : WebData DuckDbRefsResponse
    , userSqlText : String
    , fileUploadStatus : FileUploadStatus
    , nowish : Maybe Posix
    , viewport : Maybe Browser.Dom.Viewport
    , renderStatus : RenderStatus
    , selectedTableRef : Maybe DuckDbRef
    , hoveredOnTableRef : Maybe DuckDbRef
    , file : Maybe File
    , proposedCsvTargetSchemaName : String
    , proposedCsvTargetTableName : String
    }


type FileUploadStatus
    = Idle_
    | Waiting
    | Success_
    | Fail


type alias Progress =
    Float


type alias CurrentFrame =
    Int


type UiMode
    = SheetEditor
    | TimelineViewer CurrentFrame


type DataInspectMode
    = SpreadSheet
    | QueryBuilder


type Timeline
    = Timeline Model


type Msg
    = Tick Posix
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | KeyWentDown KeyCode
    | KeyReleased KeyCode
    | UserSelectedTableRef DuckDbRef
    | UserMouseEnteredTableRef DuckDbRef
    | UserMouseLeftTableRef
    | ClickedCell CellCoords
    | PromptInputChanged String
    | PromptSubmitted RawPrompt
    | ManualDom__AttemptFocus String
    | ManualDom__FocusResult (Result Browser.Dom.Error ())
    | EnterTimelineViewerMode
    | EnterSheetEditorMode -- TODO: Just toggle Ui mode?
    | QueryDuckDb String
    | UserSqlTextChanged String
      -- API response stuff:
    | GotDuckDbResponse (Result Http.Error DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error DuckDbRefsResponse)
      -- Timeline stuff:
      -- TODO: Should Msg take in a `model` param?
    | JumpToFirstFrame
    | JumpToFrame Int
    | JumpToLastFrame
    | TogglePauseResume
      -- FileUpload Msgs
    | FileUpload_UserClickedSelectFile
    | FileUpload_UserSelectedCsvFile File
    | FileUpload_UserConfirmsUpload
    | FileUpload_UploadResponded (Result Http.Error ())
    | FileUpload_UserChangedSchemaName String
    | FileUpload_UserChangedTableName String



--| FileUpload_GotProgress Http.Progress


type alias RawPrompt =
    ( RawPromptString, ( RowIx, ColIx ) )


str2Cell : String -> CellElement
str2Cell s =
    String_ s


type alias CellTypeDisplayName =
    String


cell2Str : CellElement -> ( String, CellTypeDisplayName )
cell2Str cd =
    case cd of
        Empty ->
            -- HACK: single space vs empty str yields 'expected' elm-ui table styling
            ( " ", "Empty" )

        String_ s ->
            if s == "" then
                -- HACK: single space vs empty str yields 'expected' elm-ui table styling
                ( " ", "Empty" )

            else
                ( s, "String" )

        Time_ t ->
            ( Iso.toString t, "Time" )

        Float_ f ->
            ( String.fromFloat f, "Float" )

        Int_ i ->
            ( String.fromInt i, "Integer" )

        Bool_ b ->
            case b of
                True ->
                    ( "TRUE", "Boolean" )

                False ->
                    ( "FALSE", "Boolean" )


buildSqlText : Maybe DuckDbRef -> String
buildSqlText ref =
    let
        tableRef =
            case ref of
                Nothing ->
                    "president_polls_historical"

                Just ref_ ->
                    refToString ref_
    in
    """select
    *
from """ ++ tableRef ++ """
limit 50"""


init : ( Model, Effect Msg )
init =
    let
        data : Array2D CellElement
        data =
            let
                col =
                    List.repeat 25 Empty

                rows =
                    List.repeat 100 col
            in
            fromListOfLists rows

        sheetData : SheetEnvelope
        sheetData =
            array2DToSheet data (List.map (\i -> String.fromInt i) (List.range 0 (Array2D.colCount data - 1)))

        -- NB: timeline is recursive, so we save the initial model state in this let expression, and return
        --     a partially updated model containing this one
        model : Model
        model =
            { sheet = sheetData
            , sheetMode = SpreadSheet
            , keysDown = Set.empty
            , selectedCell = Just <| ( ( 0, 0 ), Empty ) -- TODO: DRY up the ini
            , promptMode = Idle
            , submissionHistory = []
            , timeline = A.fromList []
            , uiMode = SheetEditor
            , duckDbResponse = NotAsked
            , duckDbMetaResponse = NotAsked
            , userSqlText = buildSqlText Nothing
            , fileUploadStatus = Idle_
            , nowish = Nothing
            , viewport = Nothing
            , duckDbTableRefs = Loading -- NB: this is coupled to fetchingDuckDbTable refs below
            , renderStatus = AwaitingDomInfo
            , selectedTableRef = Nothing
            , hoveredOnTableRef = Nothing
            , file = Nothing
            , proposedCsvTargetSchemaName = ""
            , proposedCsvTargetTableName = ""
            }
    in
    ( model
    , Effect.fromCmd <|
        Cmd.batch
            [ Task.perform GotViewport Browser.Dom.getViewport
            , fetchDuckDbTableRefs GotDuckDbTableRefsResponse
            ]
    )



-- UPDATE
--| Task_This
--| NewTime Time.Posix


mapColumnsToSheet : List DuckDbColumn -> SheetEnvelope
mapColumnsToSheet cols =
    let
        mapVal : Maybe FirApi.Val -> CellElement
        mapVal v =
            case v of
                Nothing ->
                    Empty

                Just val ->
                    case val of
                        FirApi.Varchar_ var ->
                            String_ var

                        FirApi.Int_ i ->
                            Int_ i

                        FirApi.Time_ t ->
                            Time_ t

                        FirApi.Bool_ b ->
                            Bool_ b

                        FirApi.Float_ f ->
                            Float_ f

                        FirApi.Unknown ->
                            Empty

        -- lol is "list of lists", but I'm also laughing at how inefficient this is
        -- TODO: I think it'd be worthwhile to refactor Array2D to accept column lists not row-lists
        lolWrong =
            List.map
                (\col ->
                    case col of
                        Persisted col_ ->
                            List.map (\e -> mapVal e) col_.vals
                )
                cols

        lolTransposed =
            LE.transpose lolWrong

        colLabels =
            List.map
                (\col ->
                    case col of
                        Persisted col_ ->
                            col_.name
                )
                cols
    in
    array2DToSheet (fromListOfLists lolTransposed) colLabels


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Tick now ->
            ( { model | nowish = Just now }, Effect.none )

        GotResizeEvent _ _ ->
            -- rather than keeping two copies of this info in memory, chain a resize event
            -- to the existing flow on first page render. This should avoid strange resizing
            -- frames from being rendered.. at least I hope so!
            ( { model | renderStatus = AwaitingDomInfo }, Effect.fromCmd (Task.perform GotViewport Browser.Dom.getViewport) )

        GotViewport viewport ->
            ( { model | viewport = Just viewport, renderStatus = Ready }, Effect.none )

        UserSelectedTableRef ref ->
            ( { model
                | selectedTableRef = Just ref
                , userSqlText = buildSqlText (Just ref)
              }
            , Effect.none
            )

        UserMouseEnteredTableRef ref ->
            ( { model
                | hoveredOnTableRef = Just ref
              }
            , Effect.none
            )

        UserMouseLeftTableRef ->
            ( { model | hoveredOnTableRef = Nothing }, Effect.none )

        GotDuckDbTableRefsResponse response ->
            case response of
                Ok refs ->
                    ( { model | duckDbTableRefs = Success refs }, Effect.none )

                Err err ->
                    ( { model | duckDbTableRefs = Failure err }, Effect.none )

        FileUpload_UserClickedSelectFile ->
            ( model, Effect.fromCmd requestFile )

        FileUpload_UserSelectedCsvFile file ->
            -- NB: We do not upload file yet, as user must fill out a small form, then click upload!
            ( { model | file = Just file }
            , Effect.none
            )

        FileUpload_UserConfirmsUpload ->
            case model.file of
                Nothing ->
                    ( model, Effect.none )

                Just csv ->
                    ( model
                    , Effect.fromCmd <|
                        uploadFile
                            csv
                            model.proposedCsvTargetSchemaName
                            model.proposedCsvTargetTableName
                            FileUpload_UploadResponded
                    )

        FileUpload_UploadResponded result ->
            -- TODO: Failure path + UI
            -- File has uploaded, clear the File from front-end model, re-fetch refs
            ( { model | file = Nothing }, Effect.fromCmd <| fetchDuckDbTableRefs GotDuckDbTableRefsResponse )

        FileUpload_UserChangedSchemaName schemaName ->
            ( { model | proposedCsvTargetSchemaName = schemaName }, Effect.none )

        FileUpload_UserChangedTableName tableName ->
            ( { model | proposedCsvTargetTableName = tableName }, Effect.none )

        UserSqlTextChanged newText ->
            ( { model | userSqlText = newText }, Effect.none )

        QueryDuckDb queryStr ->
            let
                ( shouldFallback, fallBackRef ) =
                    case model.selectedTableRef of
                        Nothing ->
                            ( False, [] )

                        Just ref ->
                            ( True, [ ref ] )
            in
            ( { model | duckDbResponse = Loading }, Effect.fromCmd <| queryDuckDb queryStr shouldFallback fallBackRef GotDuckDbResponse )

        GotDuckDbResponse response ->
            case response of
                Ok data ->
                    ( { model
                        | duckDbResponse = Success data
                        , sheet = mapColumnsToSheet data.columns
                      }
                    , Effect.none
                    )

                Err err ->
                    ( { model | duckDbResponse = Failure err }, Effect.none )

        GotDuckDbMetaResponse metaResponse ->
            case metaResponse of
                Ok data ->
                    ( { model | duckDbMetaResponse = Success data }, Effect.none )

                Err err ->
                    ( { model | duckDbMetaResponse = Failure err }, Effect.none )

        EnterSheetEditorMode ->
            ( { model | uiMode = SheetEditor }, Effect.none )

        EnterTimelineViewerMode ->
            -- NB: we assume re-entering does not remember where you were when last viewing timeline
            --     so this is effectively JumpToLastFrame. I may want to change this, so I'm keeping
            --     it a separate Msg type
            ( { model | uiMode = TimelineViewer (A.length model.timeline) }, Effect.none )

        JumpToFirstFrame ->
            ( { model | uiMode = TimelineViewer 0 }, Effect.none )

        JumpToFrame frame ->
            ( { model | uiMode = TimelineViewer frame }, Effect.none )

        JumpToLastFrame ->
            ( { model | uiMode = TimelineViewer (A.length model.timeline) }, Effect.none )

        TogglePauseResume ->
            ( model, Effect.none )

        KeyWentDown code ->
            let
                newKeys =
                    Set.insert code model.keysDown

                ( newPromptMode, cmdToSend, newSelectedCoords ) =
                    case model.selectedCell of
                        Nothing ->
                            ( Idle, Cmd.none, Nothing )

                        Just ( ( rix, lbl ), _ ) ->
                            let
                                newRix_ =
                                    if code == "ArrowUp" && rix > 0 then
                                        rix - 1

                                    else if code == "ArrowDown" then
                                        rix + 1

                                    else
                                        rix

                                newLbl_ =
                                    if code == "ArrowLeft" && lbl > 0 then
                                        lbl - 1

                                    else if code == "ArrowRight" then
                                        lbl + 1

                                    else
                                        lbl

                                newVal : CellElement
                                newVal =
                                    case elementAt ( newRix_, newLbl_ ) model.sheet of
                                        Nothing ->
                                            Empty

                                        Just v ->
                                            v
                            in
                            case model.promptMode of
                                Idle ->
                                    if code == "Enter" then
                                        ( PromptInProgress "", send <| ManualDom__AttemptFocus prompt_input_dom_id, Just ( ( newRix_, newLbl_ ), newVal ) )

                                    else
                                        ( Idle, Cmd.none, Just ( ( newRix_, newLbl_ ), newVal ) )

                                PromptInProgress v ->
                                    if code == "Enter" then
                                        ( Idle, send <| PromptSubmitted ( v, ( newRix_, newLbl_ ) ), Just ( ( newRix_, newLbl_ ), newVal ) )

                                    else
                                        ( PromptInProgress v, Cmd.none, Just ( ( newRix_, newLbl_ ), newVal ) )
            in
            ( { model
                | keysDown = newKeys
                , promptMode = newPromptMode
                , selectedCell = newSelectedCoords
              }
            , Effect.fromCmd cmdToSend
            )

        KeyReleased code ->
            let
                newKeys =
                    Set.remove code model.keysDown
            in
            ( { model | keysDown = newKeys }, Effect.none )

        ClickedCell ( rix, cix ) ->
            let
                selectedValue : CellElement
                selectedValue =
                    case elementAt ( rix, cix ) model.sheet of
                        Nothing ->
                            Empty

                        Just v ->
                            v
            in
            ( { model
                | selectedCell = Just ( ( rix, cix ), selectedValue )
              }
            , Effect.none
            )

        PromptInputChanged newStr ->
            case model.promptMode of
                Idle ->
                    ( model, Effect.none )

                PromptInProgress _ ->
                    ( { model
                        | promptMode = PromptInProgress newStr
                      }
                    , Effect.none
                    )

        PromptSubmitted ( rawSub, ( rix, cix ) ) ->
            let
                newSheetCols : SheetEnvelope
                newSheetCols =
                    { data = setValueAt ( rix, cix ) ( ( rix, cix ), str2Cell rawSub ) model.sheet.data
                    , columnLabels = model.sheet.columnLabels
                    }

                newHistory : List RawPrompt
                newHistory =
                    model.submissionHistory ++ [ ( rawSub, ( rix, cix ) ) ]

                newSelectedCoords =
                    ( rix + 1, cix )

                newSelectedValue =
                    case elementAt ( rix + 1, cix ) model.sheet of
                        Nothing ->
                            Empty

                        Just v ->
                            v

                newTimeline : A.Array Timeline
                newTimeline =
                    A.append model.timeline (A.fromList [ Timeline model ])
            in
            ( { model
                | sheet = newSheetCols
                , promptMode = Idle -- TODO: Is this redundant to key input handling?
                , submissionHistory = newHistory
                , selectedCell = Just ( newSelectedCoords, newSelectedValue )
                , timeline = newTimeline
              }
            , Effect.none
            )

        ManualDom__AttemptFocus domId ->
            ( model, Effect.fromCmd (Browser.Dom.focus domId |> Task.attempt ManualDom__FocusResult) )

        ManualDom__FocusResult result ->
            case result of
                Err _ ->
                    ( model, Effect.none )

                Ok () ->
                    ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        contextualKeystrokes : Sub Msg
        contextualKeystrokes =
            case model.uiMode of
                SheetEditor ->
                    Sub.batch
                        [ Events.onKeyDown (JD.map KeyWentDown keyDecoder)
                        , Events.onKeyUp (JD.map KeyReleased keyDecoder)
                        ]

                TimelineViewer _ ->
                    Sub.none
    in
    Sub.batch
        [ contextualKeystrokes
        , Time.every 500 Tick
        , Events.onResize GotResizeEvent
        ]



-- VIEW


view : Model -> View Msg
view model =
    let
        title =
            "Sheet Demo"

        elements : Model -> Element Msg
        elements mdl =
            case mdl.renderStatus of
                AwaitingDomInfo ->
                    E.none

                Ready ->
                    E.column
                        [ E.width E.fill
                        , E.height E.fill
                        , Background.color theme.background
                        , Font.size 12
                        , padding 5
                        ]
                        [ content mdl
                        ]

        content : Model -> Element Msg
        content mdl =
            let
                viewInstructions : Element Msg
                viewInstructions =
                    E.column [ spacing 5 ]
                        [ text "Click a cell to select it, or use arrow keys to change selection. Then, press <Enter> to propose new a value for a cell, which will be submitted upon pressing <Enter> a second time"
                        , text "This app is under development, there are bugs, but there shouldn't be any crashes"
                        ]

                model_ : Model
                model_ =
                    case mdl.uiMode of
                        SheetEditor ->
                            mdl

                        TimelineViewer i ->
                            case A.get i mdl.timeline of
                                Nothing ->
                                    mdl

                                Just v ->
                                    case v of
                                        Timeline model__ ->
                                            { model__ | uiMode = mdl.uiMode }

                ( w, h ) =
                    case mdl.viewport of
                        Nothing ->
                            ( 800, 600 )

                        Just viewport ->
                            ( round viewport.viewport.width - 20, round viewport.viewport.height - 20 )
            in
            el
                [ width (E.fill |> maximum w)
                , height (E.fill |> maximum h)
                , Border.width 1
                , Border.color theme.secondary
                , padding 5
                , spacing 5
                ]
                (row
                    [ width (E.fill |> maximum w)
                    , height (E.fill |> maximum h)
                    , spacing 5
                    ]
                    [ el
                        [ width <| E.fillPortion 8
                        , height <| E.fill
                        , Border.width 2
                        , Border.color theme.secondary
                        , clip
                        , scrollbars
                        ]
                        (viewDataInspectPanel model)
                    , el
                        [ width <| E.fillPortion 2
                        , height E.fill
                        ]
                        (column
                            [ height E.fill
                            , width E.fill
                            , Border.width 1
                            , Border.color theme.secondary
                            ]
                            [ el
                                [ width E.fill
                                , height <| E.fillPortion 4
                                , Border.width 1
                                , Border.color theme.secondary
                                ]
                                (viewCatalogPanel model)
                            , el
                                [ width E.fill
                                , height <| E.fillPortion 4
                                , Border.width 1
                                , Border.color theme.secondary
                                ]
                                (viewSqlInputPanel model)
                            , el
                                [ width E.fill
                                , height <| E.fillPortion 2
                                , Border.width 1
                                , Border.color theme.secondary
                                ]
                                (viewDebugPanel model)
                            ]
                        )
                    ]
                )
    in
    { title = title
    , body =
        elements model
    }


viewDataInspectPanel : Model -> Element Msg
viewDataInspectPanel model =
    let
        viewSheet : Element Msg
        viewSheet =
            let
                attrs : List (Attribute Msg)
                attrs =
                    [ height fill
                    , width fill
                    ]

                viewSheetColumn : ColIx -> ColumnLabel -> A.Array Cell -> Element Msg
                viewSheetColumn cix lbl column =
                    let
                        cellAttrs : RowIx -> List (Attribute Msg)
                        cellAttrs rix =
                            let
                                shouldHighlightCell : Bool
                                shouldHighlightCell =
                                    case model.selectedCell of
                                        Nothing ->
                                            False

                                        Just ( ( rix_, cix_ ), _ ) ->
                                            (rix_ == rix) && (cix_ == cix)

                                borderWidth =
                                    case shouldHighlightCell of
                                        False ->
                                            1

                                        True ->
                                            3

                                borderColor =
                                    case shouldHighlightCell of
                                        False ->
                                            theme.gray

                                        True ->
                                            theme.primary1
                            in
                            [ Border.color borderColor
                            , Border.width borderWidth
                            , onClick <| ClickedCell ( rix, cix )

                            --, paddingEach { top = 1, left = 0, right = 0, bottom = 1 }
                            ]

                        cellContentAttrs : CellElement -> List (Attribute Msg)
                        cellContentAttrs ce =
                            let
                                alignment =
                                    case ce of
                                        Empty ->
                                            centerX

                                        String_ _ ->
                                            alignLeft

                                        Time_ _ ->
                                            alignLeft

                                        Bool_ _ ->
                                            centerX

                                        Float_ _ ->
                                            alignRight

                                        Int_ _ ->
                                            alignRight
                            in
                            [ alignment
                            , paddingEach { top = 1, left = 0, right = 0, bottom = 1 }
                            ]

                        viewCell : Maybe ( CellCoords, CellElement ) -> CellElement -> String -> RowIx -> PromptMode -> Element Msg
                        viewCell selectedCoords ce cellValueAsStr rix_ promptMode =
                            let
                                isTargetCell : Bool
                                isTargetCell =
                                    case selectedCoords of
                                        Nothing ->
                                            False

                                        Just ( ( rix__, cix_ ), _ ) ->
                                            (rix_ == rix__) && (cix_ == cix)
                            in
                            case isTargetCell of
                                True ->
                                    case promptMode of
                                        Idle ->
                                            E.text cellValueAsStr

                                        PromptInProgress v ->
                                            Input.text
                                                [ htmlAttribute <| HA.id prompt_input_dom_id
                                                , padding 0
                                                , Border.width 0
                                                ]
                                                { text = v
                                                , onChange = PromptInputChanged
                                                , label = Input.labelHidden ""
                                                , placeholder = Nothing
                                                }

                                False ->
                                    el (cellContentAttrs ce ++ [ width fill ]) (textWithEllipsis cellValueAsStr)
                    in
                    E.table
                        [ padding 0 ]
                        { data = A.toList column
                        , columns =
                            [ { header = textWithEllipsis <| "[" ++ lbl ++ "]"
                              , width = px 80
                              , view =
                                    \( ( rix, _ ), cellElement ) ->
                                        E.el (cellAttrs rix)
                                            (viewCell model.selectedCell cellElement (Tuple.first (cell2Str cellElement)) rix model.promptMode)
                              }
                            ]
                        }
            in
            row attrs
                (A.toList <|
                    Array2D.map2
                        (\cix lbl -> viewSheetColumn cix lbl (getCol cix model.sheet.data))
                        (A.fromList (List.range 0 (colCount model.sheet.data - 1)))
                        (A.fromList model.sheet.columnLabels)
                )
    in
    column
        [ padding 5
        ]
        [ viewSheet
        ]


viewSqlInputPanel : Model -> Element Msg
viewSqlInputPanel model =
    let
        viewDuckDbButton : Element Msg
        viewDuckDbButton =
            Input.button
                [ Border.color theme.secondary
                , Border.width 1
                , Border.rounded 4
                , padding 4
                , alignTop
                , alignRight
                , Background.color theme.background
                ]
                { onPress = Just <| QueryDuckDb model.userSqlText
                , label = text "Query DuckDB"
                }

        viewSqlInput : Element Msg
        viewSqlInput =
            let
                label =
                    case model.selectedTableRef of
                        Nothing ->
                            "Select a table ref below, or upload a new CSV"

                        Just ref ->
                            refToString ref
            in
            Input.multiline
                [ width fill
                , height fill
                , Border.rounded 6
                , Border.width 2
                , Border.color <| rgb255 0x72 0x9F 0xCF
                ]
                { onChange = UserSqlTextChanged
                , text = model.userSqlText
                , placeholder = Just <| Input.placeholder [] <| text "Type your message"
                , label = Input.labelAbove [] <| text label
                , spellcheck = True
                }

        viewError : Element Msg
        viewError =
            let
                errAttrs =
                    el
                        [ Background.color theme.background
                        , Border.width 2
                        , Border.color theme.secondary
                        ]
            in
            case model.duckDbResponse of
                Failure err ->
                    case err of
                        BadUrl url ->
                            errAttrs <| text <| "Bad url: " ++ url

                        Timeout ->
                            errAttrs <| text <| "Request timed out!"

                        BadStatus int ->
                            errAttrs <| text <| "Http status: " ++ String.fromInt int

                        NetworkError ->
                            errAttrs <| text <| "An unknown network error!"

                        BadBody s ->
                            errAttrs <| text <| "Bad body: " ++ s

                _ ->
                    E.none
    in
    E.column
        [ width fill
        , height fill
        ]
        [ viewSqlInput
        , viewDuckDbButton
        , viewError
        ]


viewTimelinePanel : Model -> Element Msg
viewTimelinePanel model =
    case model.uiMode of
        SheetEditor ->
            Input.button
                [ Border.color theme.secondary
                , Border.width 1
                , Border.rounded 4
                , padding 4
                , alignTop
                , Background.color theme.background
                ]
                { onPress = Just <| EnterTimelineViewerMode
                , label = text "Enter Timeline Mode"
                }

        TimelineViewer frame ->
            let
                previousFrame =
                    if frame > 0 then
                        frame - 1

                    else
                        0

                nextFrame =
                    if frame == A.length model.timeline - 1 then
                        frame

                    else
                        frame + 1
            in
            E.column []
                [ E.text <|
                    "You are currently viewing frame "
                        ++ String.fromInt frame
                , E.row
                    [ padding 5
                    , spacing 5
                    ]
                    [ Input.button
                        [ Border.color theme.black
                        , Border.width 1
                        , Border.rounded 4
                        , padding 4
                        , alignTop
                        , Background.color theme.secondary
                        ]
                        { onPress = Just <| EnterSheetEditorMode
                        , label = text "Back to Edit Mode"
                        }
                    , Input.button
                        [ Border.color theme.black
                        , Border.width 1
                        , Border.rounded 4
                        , padding 4
                        , alignTop
                        , Background.color theme.secondary
                        ]
                        { onPress = Just <| JumpToFirstFrame
                        , label = text "<|-"
                        }
                    , Input.button
                        [ Border.color theme.black
                        , Border.width 1
                        , Border.rounded 4
                        , padding 4
                        , alignTop
                        , Background.color theme.background
                        ]
                        { onPress = Just <| JumpToFrame previousFrame
                        , label = text "<"
                        }
                    , Input.button
                        [ Border.color theme.black
                        , Border.width 1
                        , Border.rounded 4
                        , padding 4
                        , alignTop
                        , Background.color theme.secondary
                        ]
                        { onPress = Just <| TogglePauseResume
                        , label = text "||"
                        }
                    , Input.button
                        [ Border.color theme.black
                        , Border.width 1
                        , Border.rounded 4
                        , padding 4
                        , alignTop
                        , Background.color theme.secondary
                        ]
                        { onPress = Just <| JumpToFrame nextFrame
                        , label = text ">"
                        }
                    , Input.button
                        [ Border.color theme.black
                        , Border.width 1
                        , Border.rounded 4
                        , padding 4
                        , alignTop
                        , Background.color theme.secondary
                        ]
                        { onPress = Just <| JumpToLastFrame
                        , label = text "-|>"
                        }
                    ]
                ]


viewDebugPanel : Model -> Element Msg
viewDebugPanel model =
    let
        keysList =
            Set.toList model.keysDown

        keyString =
            String.join "," keysList

        selectedCoordsStr =
            case model.selectedCell of
                Nothing ->
                    "Click a cell to select it"

                Just ( ( rix, lbl ), _ ) ->
                    "Selection: (" ++ String.fromInt rix ++ ", " ++ String.fromInt lbl ++ ")"

        selectedValueStr =
            case model.selectedCell of
                Nothing ->
                    "No selected value"

                Just ( _, v ) ->
                    let
                        ( value, typeDisplayName ) =
                            cell2Str v
                    in
                    "Value: " ++ value ++ " [" ++ typeDisplayName ++ "]"

        viewPromptHistory : List RawPrompt -> Element Msg
        viewPromptHistory history =
            let
                promptStr : RawPrompt -> Element Msg
                promptStr prompt =
                    case prompt of
                        ( rawStr, ( rix, lbl ) ) ->
                            text <| "    " ++ rawStr ++ " @:(" ++ String.fromInt rix ++ ", " ++ String.fromInt lbl ++ ")"
            in
            column []
                [ text <| "Submission history:"
                , column [ spacing 2 ] <| List.map promptStr history
                ]
    in
    column
        [ width E.fill
        , height E.fill
        , spacing 2
        ]
        [ text "Debug info:"
        , text keyString
        , text selectedCoordsStr
        , text selectedValueStr
        , viewPromptHistory model.submissionHistory
        ]


requestFile : Cmd Msg
requestFile =
    Select.file [ "application/csv" ] FileUpload_UserSelectedCsvFile


viewCatalogPanel : Model -> Element Msg
viewCatalogPanel model =
    let
        viewTableRefs : Element Msg
        viewTableRefs =
            case model.duckDbTableRefs of
                NotAsked ->
                    text " "

                Loading ->
                    text "Fetching..."

                Success refsResponse ->
                    let
                        refsSelector : List DuckDbRef -> Element Msg
                        refsSelector refs =
                            let
                                backgroundColorFor : DuckDbRef -> Color
                                backgroundColorFor ref =
                                    case model.hoveredOnTableRef of
                                        Nothing ->
                                            theme.background

                                        Just ref_ ->
                                            if refEquals ref ref_ then
                                                theme.primary1

                                            else
                                                theme.background

                                borderColorFor ref =
                                    case model.hoveredOnTableRef of
                                        Nothing ->
                                            theme.background

                                        Just ref_ ->
                                            if ref == ref_ then
                                                theme.primary1

                                            else
                                                theme.background

                                borderFor ref =
                                    case model.hoveredOnTableRef of
                                        Nothing ->
                                            { top = 1, left = 0, right = 0, bottom = 1 }

                                        Just ref_ ->
                                            if ref == ref_ then
                                                { top = 1, left = 0, right = 0, bottom = 1 }

                                            else
                                                { top = 1, left = 0, right = 0, bottom = 1 }

                                innerBlobColorFor ref =
                                    case model.hoveredOnTableRef of
                                        Nothing ->
                                            theme.background

                                        Just ref_ ->
                                            if ref == ref_ then
                                                theme.primary2

                                            else
                                                theme.background

                                ui : DuckDbRef -> Element Msg
                                ui ref =
                                    row
                                        [ width E.fill
                                        , paddingXY 0 2
                                        , spacingXY 2 0
                                        , onClick <| UserSelectedTableRef ref
                                        , onMouseEnter <| UserMouseEnteredTableRef ref
                                        , onMouseLeave <| UserMouseLeftTableRef
                                        , Background.color (backgroundColorFor ref)
                                        , Border.widthEach (borderFor ref)
                                        , Border.color (borderColorFor ref)
                                        ]
                                        [ el
                                            [ width <| px 5
                                            , height <| px 5
                                            , Border.width 1
                                            , Background.color (innerBlobColorFor ref)
                                            ]
                                            E.none
                                        , text <| refToString ref
                                        ]
                            in
                            column
                                [ width E.fill
                                , height E.fill
                                , paddingXY 5 0
                                , clip
                                , scrollbarY
                                ]
                            <|
                                List.map (\ref -> ui ref) refs
                    in
                    column
                        [ width E.fill
                        , height E.fill
                        , spacing 2
                        ]
                        [ text "DuckDB Refs:"
                        , refsSelector refsResponse.refs
                        ]

                Failure err ->
                    text "Error"

        viewUploadFilePanel : Element Msg
        viewUploadFilePanel =
            let
                shouldAllowUpload : String -> String -> Bool
                shouldAllowUpload schemaName tableName =
                    if String.length schemaName >= 2 && String.length tableName >= 4 then
                        True

                    else
                        False

                uploadButton : Element Msg
                uploadButton =
                    case shouldAllowUpload model.proposedCsvTargetSchemaName model.proposedCsvTargetTableName of
                        True ->
                            Input.button
                                [ alignBottom
                                , alignRight
                                , padding 5
                                , Border.color theme.secondary
                                , Border.width 4
                                , Border.rounded 3
                                , Background.color theme.background
                                ]
                                { onPress = Just FileUpload_UserConfirmsUpload
                                , label = text "Upload"
                                }

                        False ->
                            -- TODO: Theme for "faded out" variant of button
                            Input.button
                                [ alignBottom
                                , alignRight
                                , padding 5
                                , Border.color theme.secondary
                                , Border.width 1

                                --, Font.color Ui.lightGrey
                                , Border.rounded 3
                                , Background.color theme.background
                                ]
                                { onPress = Nothing
                                , label = text "Finish form to upload"
                                }
            in
            case model.file of
                Nothing ->
                    -- The user has either 1) not yet selected a file, or 2) successfully uploaded a file. So show
                    -- select file button
                    Input.button
                        [ alignBottom
                        , alignRight
                        , padding 5
                        , Border.color theme.secondary
                        , Border.width 1
                        , Border.rounded 3
                        , Background.color theme.background
                        ]
                        { onPress = Just FileUpload_UserClickedSelectFile
                        , label = text "Upload CSV File"
                        }

                Just _ ->
                    -- The user has selected a file locally, but must fill out form prior to upload
                    -- we don't do anything here with the file itself, it's just saved to the front-end model
                    column
                        [ alignBottom
                        , width fill
                        ]
                        [ Input.text []
                            { onChange = FileUpload_UserChangedSchemaName
                            , text = model.proposedCsvTargetSchemaName
                            , placeholder = Just <| Input.placeholder [] (E.text "2+ letters, one word")
                            , label = Input.labelLeft [] (E.text "Schema Name:")
                            }
                        , Input.text []
                            { onChange = FileUpload_UserChangedTableName
                            , text = model.proposedCsvTargetTableName
                            , placeholder = Just <| Input.placeholder [] (E.text "4+ letters, one word")
                            , label = Input.labelLeft [] (E.text "Table Name:")
                            }
                        , uploadButton
                        ]
    in
    column
        [ width E.fill
        , height E.fill
        ]
        [ viewTableRefs
        , viewUploadFilePanel
        ]



-- begin region view utils


textWithEllipsis : String -> Element Msg
textWithEllipsis displayText =
    -- Workaround, see link for info: https://github.com/mdgriffith/elm-ui/issues/112
    E.html
        (H.div
            [ HA.style "text-overflow" "ellipsis"
            , HA.style "overflow" "hidden"
            ]
            [ H.text displayText ]
        )



-- end region view utils
-- begin region misc utils


prompt_input_dom_id : String
prompt_input_dom_id =
    -- page-scoped, static unique identifier to control focus manually
    "prompt-input-element"



-- end region misc utils
