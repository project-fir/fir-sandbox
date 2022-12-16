module Evergreen.V50.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V50.Bridge
import Evergreen.V50.DimensionalModel
import Evergreen.V50.DuckDb
import Evergreen.V50.Ui
import Evergreen.V50.Utils
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
    | DragInitiated Evergreen.V50.DuckDb.DuckDbRef
    | Dragging Evergreen.V50.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V50.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V50.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V50.DuckDb.DuckDbColumnDescription Evergreen.V50.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V50.Bridge.BackendData (List Evergreen.V50.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V50.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V50.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V50.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V50.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V50.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V50.Bridge.BackendData (List Evergreen.V50.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V50.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V50.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V50.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V50.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V50.Utils.KeyCode
    , theme : Evergreen.V50.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V50.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V50.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V50.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V50.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V50.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V50.DuckDb.DuckDbRef
    | UserToggledCardDropDown Evergreen.V50.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V50.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V50.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V50.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V50.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V50.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V50.DimensionalModel.DimensionalModelRef Evergreen.V50.DuckDb.DuckDbRef (Evergreen.V50.DimensionalModel.KimballAssignment Evergreen.V50.DuckDb.DuckDbRef_ (List Evergreen.V50.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V50.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
