module Evergreen.V46.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V46.Bridge
import Evergreen.V46.DimensionalModel
import Evergreen.V46.DuckDb
import Evergreen.V46.Ui
import Evergreen.V46.Utils
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
    | DragInitiated Evergreen.V46.DuckDb.DuckDbRef
    | Dragging Evergreen.V46.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V46.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V46.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V46.DuckDb.DuckDbColumnDescription Evergreen.V46.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V46.Bridge.BackendData (List Evergreen.V46.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V46.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V46.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V46.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V46.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V46.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V46.Bridge.BackendData (List Evergreen.V46.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V46.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V46.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V46.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V46.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V46.Utils.KeyCode
    , theme : Evergreen.V46.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V46.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V46.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V46.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V46.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V46.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V46.DuckDb.DuckDbRef
    | UserToggledCardDropDown Evergreen.V46.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V46.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V46.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V46.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V46.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V46.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V46.DimensionalModel.DimensionalModelRef Evergreen.V46.DuckDb.DuckDbRef (Evergreen.V46.DimensionalModel.KimballAssignment Evergreen.V46.DuckDb.DuckDbRef_ (List Evergreen.V46.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V46.DuckDb.DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode
