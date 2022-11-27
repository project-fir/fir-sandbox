module Evergreen.V39.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V39.Bridge
import Evergreen.V39.DimensionalModel
import Evergreen.V39.DuckDb
import Evergreen.V39.Ui
import Evergreen.V39.Utils
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
    | DragInitiated Evergreen.V39.DuckDb.DuckDbRef
    | Dragging Evergreen.V39.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V39.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V39.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V39.DuckDb.DuckDbColumnDescription Evergreen.V39.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V39.Bridge.BackendData (List Evergreen.V39.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V39.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V39.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V39.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V39.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V39.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V39.Bridge.BackendData (List Evergreen.V39.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V39.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V39.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V39.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V39.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V39.Utils.KeyCode
    , theme : Evergreen.V39.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V39.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V39.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V39.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V39.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V39.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V39.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V39.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V39.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V39.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V39.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V39.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V39.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V39.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V39.DimensionalModel.DimensionalModelRef Evergreen.V39.DuckDb.DuckDbRef (Evergreen.V39.DimensionalModel.KimballAssignment Evergreen.V39.DuckDb.DuckDbRef_ (List Evergreen.V39.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V39.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
