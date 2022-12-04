module Evergreen.V40.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V40.Bridge
import Evergreen.V40.DimensionalModel
import Evergreen.V40.DuckDb
import Evergreen.V40.Ui
import Evergreen.V40.Utils
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
    | DragInitiated Evergreen.V40.DuckDb.DuckDbRef
    | Dragging Evergreen.V40.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V40.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V40.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V40.DuckDb.DuckDbColumnDescription Evergreen.V40.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V40.Bridge.BackendData (List Evergreen.V40.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V40.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V40.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V40.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V40.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V40.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V40.Bridge.BackendData (List Evergreen.V40.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V40.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V40.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V40.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V40.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V40.Utils.KeyCode
    , theme : Evergreen.V40.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V40.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V40.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V40.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V40.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V40.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V40.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V40.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V40.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V40.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V40.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V40.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V40.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V40.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V40.DimensionalModel.DimensionalModelRef Evergreen.V40.DuckDb.DuckDbRef (Evergreen.V40.DimensionalModel.KimballAssignment Evergreen.V40.DuckDb.DuckDbRef_ (List Evergreen.V40.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V40.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
