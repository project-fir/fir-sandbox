module Evergreen.V54.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V54.Bridge
import Evergreen.V54.DimensionalModel
import Evergreen.V54.DuckDb
import Evergreen.V54.Ui
import Evergreen.V54.Utils
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
    | DragInitiated Evergreen.V54.DuckDb.DuckDbRef
    | Dragging Evergreen.V54.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V54.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V54.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V54.DuckDb.DuckDbColumnDescription Evergreen.V54.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V54.Bridge.BackendData (List Evergreen.V54.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V54.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V54.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V54.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V54.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V54.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V54.Bridge.BackendData (List Evergreen.V54.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V54.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V54.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V54.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V54.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V54.Utils.KeyCode
    , theme : Evergreen.V54.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V54.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V54.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V54.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V54.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V54.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V54.DuckDb.DuckDbRef
    | UserToggledCardDropDown Evergreen.V54.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V54.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V54.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V54.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V54.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V54.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V54.DimensionalModel.DimensionalModelRef Evergreen.V54.DuckDb.DuckDbRef (Evergreen.V54.DimensionalModel.KimballAssignment Evergreen.V54.DuckDb.DuckDbRef_ (List Evergreen.V54.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V54.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
