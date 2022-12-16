module Evergreen.V49.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V49.Bridge
import Evergreen.V49.DimensionalModel
import Evergreen.V49.DuckDb
import Evergreen.V49.Ui
import Evergreen.V49.Utils
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
    | DragInitiated Evergreen.V49.DuckDb.DuckDbRef
    | Dragging Evergreen.V49.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V49.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V49.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V49.DuckDb.DuckDbColumnDescription Evergreen.V49.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V49.Bridge.BackendData (List Evergreen.V49.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V49.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V49.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V49.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V49.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V49.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V49.Bridge.BackendData (List Evergreen.V49.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V49.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V49.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V49.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V49.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V49.Utils.KeyCode
    , theme : Evergreen.V49.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V49.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V49.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V49.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V49.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V49.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V49.DuckDb.DuckDbRef
    | UserToggledCardDropDown Evergreen.V49.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V49.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V49.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V49.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V49.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V49.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V49.DimensionalModel.DimensionalModelRef Evergreen.V49.DuckDb.DuckDbRef (Evergreen.V49.DimensionalModel.KimballAssignment Evergreen.V49.DuckDb.DuckDbRef_ (List Evergreen.V49.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V49.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
