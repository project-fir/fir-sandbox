module Evergreen.V43.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V43.Bridge
import Evergreen.V43.DimensionalModel
import Evergreen.V43.DuckDb
import Evergreen.V43.Ui
import Evergreen.V43.Utils
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
    | DragInitiated Evergreen.V43.DuckDb.DuckDbRef
    | Dragging Evergreen.V43.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V43.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V43.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V43.DuckDb.DuckDbColumnDescription Evergreen.V43.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V43.Bridge.BackendData (List Evergreen.V43.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V43.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V43.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V43.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V43.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V43.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V43.Bridge.BackendData (List Evergreen.V43.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V43.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V43.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V43.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V43.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V43.Utils.KeyCode
    , theme : Evergreen.V43.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V43.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V43.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V43.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V43.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V43.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V43.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V43.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V43.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V43.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V43.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V43.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V43.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V43.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V43.DimensionalModel.DimensionalModelRef Evergreen.V43.DuckDb.DuckDbRef (Evergreen.V43.DimensionalModel.KimballAssignment Evergreen.V43.DuckDb.DuckDbRef_ (List Evergreen.V43.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V43.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
