module Evergreen.V41.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V41.Bridge
import Evergreen.V41.DimensionalModel
import Evergreen.V41.DuckDb
import Evergreen.V41.Ui
import Evergreen.V41.Utils
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
    | DragInitiated Evergreen.V41.DuckDb.DuckDbRef
    | Dragging Evergreen.V41.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V41.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V41.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V41.DuckDb.DuckDbColumnDescription Evergreen.V41.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V41.Bridge.BackendData (List Evergreen.V41.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V41.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V41.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V41.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V41.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V41.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V41.Bridge.BackendData (List Evergreen.V41.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V41.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V41.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V41.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V41.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V41.Utils.KeyCode
    , theme : Evergreen.V41.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V41.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V41.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V41.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V41.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V41.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V41.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V41.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V41.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V41.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V41.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V41.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V41.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V41.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V41.DimensionalModel.DimensionalModelRef Evergreen.V41.DuckDb.DuckDbRef (Evergreen.V41.DimensionalModel.KimballAssignment Evergreen.V41.DuckDb.DuckDbRef_ (List Evergreen.V41.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V41.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
