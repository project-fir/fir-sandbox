module Evergreen.V5.Pages.Sheet exposing (..)

import Array
import Browser.Dom
import Evergreen.V5.Api
import Evergreen.V5.Array2D
import Evergreen.V5.SheetModel
import File
import Http
import RemoteData
import Set
import Time


type DataInspectMode
    = SpreadSheet
    | QueryBuilder


type alias KeyCode =
    String


type PromptMode
    = Idle
    | PromptInProgress String


type alias RawPrompt =
    ( Evergreen.V5.SheetModel.RawPromptString, ( Evergreen.V5.Array2D.RowIx, Evergreen.V5.Array2D.ColIx ) )


type alias CurrentFrame =
    Int


type UiMode
    = SheetEditor
    | TimelineViewer CurrentFrame


type FileUploadStatus
    = Idle_
    | Waiting
    | Success_
    | Fail


type RenderStatus
    = AwaitingDomInfo
    | Ready


type alias Model =
    { sheet : Evergreen.V5.SheetModel.SheetEnvelope
    , sheetMode : DataInspectMode
    , keysDown : Set.Set KeyCode
    , selectedCell : Maybe Evergreen.V5.SheetModel.Cell
    , promptMode : PromptMode
    , submissionHistory : List RawPrompt
    , timeline : Array.Array Timeline
    , uiMode : UiMode
    , duckDbResponse : RemoteData.WebData Evergreen.V5.Api.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V5.Api.DuckDbQueryResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V5.Api.DuckDbTableRefsResponse
    , userSqlText : String
    , fileUploadStatus : FileUploadStatus
    , nowish : Maybe Time.Posix
    , viewport : Maybe Browser.Dom.Viewport
    , renderStatus : RenderStatus
    , selectedTableRef : Maybe Evergreen.V5.Api.TableRef
    , hoveredOnTableRef : Maybe Evergreen.V5.Api.TableRef
    }


type Timeline
    = Timeline Model


type Msg
    = Tick Time.Posix
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | KeyWentDown KeyCode
    | KeyReleased KeyCode
    | UserSelectedTableRef Evergreen.V5.Api.TableRef
    | UserMouseEnteredTableRef Evergreen.V5.Api.TableRef
    | UserMouseLeftTableRef
    | ClickedCell Evergreen.V5.SheetModel.CellCoords
    | PromptInputChanged String
    | PromptSubmitted RawPrompt
    | ManualDom__AttemptFocus String
    | ManualDom__FocusResult (Result Browser.Dom.Error ())
    | EnterTimelineViewerMode
    | EnterSheetEditorMode
    | QueryDuckDb String
    | UserSqlTextChanged String
    | GotDuckDbResponse (Result Http.Error Evergreen.V5.Api.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V5.Api.DuckDbQueryResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V5.Api.DuckDbTableRefsResponse)
    | JumpToFirstFrame
    | JumpToFrame Int
    | JumpToLastFrame
    | TogglePauseResume
    | FileUpload_UserClickedSelectFile
    | FileUpload_UserSelectedCsvFile File.File
    | FileUpload_UploadResponded (Result Http.Error ())
