module Evergreen.V52.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V52.Bridge
import Evergreen.V52.DimensionalModel
import Evergreen.V52.DuckDb
import Evergreen.V52.Ui
import Evergreen.V52.Utils
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
    | DragInitiated Evergreen.V52.DuckDb.DuckDbRef
    | Dragging Evergreen.V52.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V52.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V52.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V52.DuckDb.DuckDbColumnDescription Evergreen.V52.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V52.Bridge.BackendData (List Evergreen.V52.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V52.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V52.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V52.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V52.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V52.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V52.Bridge.BackendData (List Evergreen.V52.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V52.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V52.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V52.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V52.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V52.Utils.KeyCode
    , theme : Evergreen.V52.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V52.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V52.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V52.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V52.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V52.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V52.DuckDb.DuckDbRef
    | UserToggledCardDropDown Evergreen.V52.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V52.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V52.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V52.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V52.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V52.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V52.DimensionalModel.DimensionalModelRef Evergreen.V52.DuckDb.DuckDbRef (Evergreen.V52.DimensionalModel.KimballAssignment Evergreen.V52.DuckDb.DuckDbRef_ (List Evergreen.V52.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V52.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
