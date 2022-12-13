module Evergreen.V45.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V45.Bridge
import Evergreen.V45.DimensionalModel
import Evergreen.V45.DuckDb
import Evergreen.V45.Ui
import Evergreen.V45.Utils
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
    | DragInitiated Evergreen.V45.DuckDb.DuckDbRef
    | Dragging Evergreen.V45.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V45.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V45.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V45.DuckDb.DuckDbColumnDescription Evergreen.V45.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V45.Bridge.BackendData (List Evergreen.V45.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V45.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V45.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V45.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V45.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V45.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V45.Bridge.BackendData (List Evergreen.V45.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V45.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V45.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V45.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V45.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V45.Utils.KeyCode
    , theme : Evergreen.V45.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V45.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V45.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V45.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V45.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V45.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V45.DuckDb.DuckDbRef
    | UserToggledCardDropDown Evergreen.V45.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V45.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V45.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V45.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V45.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V45.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V45.DimensionalModel.DimensionalModelRef Evergreen.V45.DuckDb.DuckDbRef (Evergreen.V45.DimensionalModel.KimballAssignment Evergreen.V45.DuckDb.DuckDbRef_ (List Evergreen.V45.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V45.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
