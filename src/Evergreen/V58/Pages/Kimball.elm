module Evergreen.V58.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V58.Bridge
import Evergreen.V58.DimensionalModel
import Evergreen.V58.DuckDb
import Evergreen.V58.Ui
import Evergreen.V58.Utils
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
    | DragInitiated Evergreen.V58.DuckDb.DuckDbRef
    | Dragging Evergreen.V58.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V58.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V58.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V58.DuckDb.DuckDbColumnDescription Evergreen.V58.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V58.Bridge.BackendData (List Evergreen.V58.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V58.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V58.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V58.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V58.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V58.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V58.Bridge.BackendData (List Evergreen.V58.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V58.DimensionalModel.DimensionalModel
    , opened222 : Maybe Evergreen.V58.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V58.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V58.Utils.KeyCode
    , theme : Evergreen.V58.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V58.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V58.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V58.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V58.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V58.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V58.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V58.DimensionalModel.DimensionalModelRef
    | MouseEnteredErdCard Evergreen.V58.DuckDb.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V58.DuckDb.DuckDbRef Evergreen.V58.DuckDb.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V58.DuckDb.DuckDbRef Evergreen.V58.DuckDb.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V58.DuckDb.DuckDbRef
    | ClickedErdCardDropdownOption Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DuckDb.DuckDbRef (Evergreen.V58.DimensionalModel.KimballAssignment Evergreen.V58.DuckDb.DuckDbRef_ (List Evergreen.V58.DuckDb.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V58.DuckDb.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event
    | SvgViewBoxTransform SvgViewBoxTransformation
    | UserSelectedCursorMode CursorMode
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | TerminateDrags
    | ClearNodeHoverState
    | KimballNoop
    | KimballNoop_ Evergreen.V58.DuckDb.DuckDbRef
    | KimballNoop__ Int
