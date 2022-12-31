module Evergreen.V63.Pages.Sheet exposing (..)

import Array
import Browser.Dom
import Evergreen.V63.Array2D
import Evergreen.V63.FirApi
import Evergreen.V63.SheetModel
import Evergreen.V63.Utils
import File
import Http
import RemoteData
import Set
import Time


type DataInspectMode
    = SpreadSheet
    | QueryBuilder


type PromptMode
    = Idle
    | PromptInProgress String


type alias RawPrompt =
    ( Evergreen.V63.SheetModel.RawPromptString, ( Evergreen.V63.Array2D.RowIx, Evergreen.V63.Array2D.ColIx ) )


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
    { sheet : Evergreen.V63.SheetModel.SheetEnvelope
    , sheetMode : DataInspectMode
    , keysDown : Set.Set Evergreen.V63.Utils.KeyCode
    , selectedCell : Maybe Evergreen.V63.SheetModel.Cell
    , promptMode : PromptMode
    , submissionHistory : List RawPrompt
    , timeline : Array.Array Timeline
    , uiMode : UiMode
    , duckDbResponse : RemoteData.WebData Evergreen.V63.FirApi.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V63.FirApi.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V63.FirApi.DuckDbRefsResponse
    , userSqlText : String
    , fileUploadStatus : FileUploadStatus
    , nowish : Maybe Time.Posix
    , viewport : Maybe Browser.Dom.Viewport
    , renderStatus : RenderStatus
    , selectedTableRef : Maybe Evergreen.V63.FirApi.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V63.FirApi.DuckDbRef
    , file : Maybe File.File
    , proposedCsvTargetSchemaName : String
    , proposedCsvTargetTableName : String
    }


type Timeline
    = Timeline Model


type Msg
    = Tick Time.Posix
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | KeyWentDown Evergreen.V63.Utils.KeyCode
    | KeyReleased Evergreen.V63.Utils.KeyCode
    | UserSelectedTableRef Evergreen.V63.FirApi.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V63.FirApi.DuckDbRef
    | UserMouseLeftTableRef
    | ClickedCell Evergreen.V63.SheetModel.CellCoords
    | PromptInputChanged String
    | PromptSubmitted RawPrompt
    | ManualDom__AttemptFocus String
    | ManualDom__FocusResult (Result Browser.Dom.Error ())
    | EnterTimelineViewerMode
    | EnterSheetEditorMode
    | QueryDuckDb String
    | UserSqlTextChanged String
    | GotDuckDbResponse (Result Http.Error Evergreen.V63.FirApi.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V63.FirApi.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V63.FirApi.DuckDbRefsResponse)
    | JumpToFirstFrame
    | JumpToFrame Int
    | JumpToLastFrame
    | TogglePauseResume
    | FileUpload_UserClickedSelectFile
    | FileUpload_UserSelectedCsvFile File.File
    | FileUpload_UserConfirmsUpload
    | FileUpload_UploadResponded (Result Http.Error ())
    | FileUpload_UserChangedSchemaName String
    | FileUpload_UserChangedTableName String
