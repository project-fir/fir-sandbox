module Evergreen.V48.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V48.Bridge
import Evergreen.V48.DimensionalModel
import Evergreen.V48.DuckDb
import Evergreen.V48.Ui
import Evergreen.V48.Utils
import Html.Events.Extra.Mouse
import Set


type alias LayoutInfo =
    { mainPanelWidth : Int
    , mainPanelHeight : Int
    , sidePanelWidth : Int
    , canvasElementWidth : Float
    , canvasElementHeight : Float
    , viewBoxXMin : Float
    , viewBoxYMin : Float
    , viewBoxWidth : Float
    , viewBoxHeight : Float
    }


type PageRenderStatus
    = AwaitingDomInfo
    | Ready LayoutInfo


type DragState
    = Idle
    | DragInitiated Evergreen.V48.DuckDb.DuckDbRef
    | Dragging Evergreen.V48.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V48.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V48.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V48.DuckDb.DuckDbColumnDescription Evergreen.V48.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V48.Bridge.BackendData (List Evergreen.V48.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V48.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V48.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V48.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V48.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V48.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V48.Bridge.BackendData (List Evergreen.V48.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V48.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V48.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V48.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V48.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V48.Utils.KeyCode
    , theme : Evergreen.V48.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V48.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V48.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V48.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V48.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V48.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V48.DuckDb.DuckDbRef
    | UserToggledCardDropDown Evergreen.V48.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V48.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V48.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V48.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V48.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V48.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V48.DimensionalModel.DimensionalModelRef Evergreen.V48.DuckDb.DuckDbRef (Evergreen.V48.DimensionalModel.KimballAssignment Evergreen.V48.DuckDb.DuckDbRef_ (List Evergreen.V48.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V48.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
