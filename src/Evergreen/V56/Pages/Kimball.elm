module Evergreen.V56.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V56.Bridge
import Evergreen.V56.DimensionalModel
import Evergreen.V56.DuckDb
import Evergreen.V56.Ui
import Evergreen.V56.Utils
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
    | DragInitiated Evergreen.V56.DuckDb.DuckDbRef
    | Dragging Evergreen.V56.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V56.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V56.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V56.DuckDb.DuckDbColumnDescription Evergreen.V56.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V56.Bridge.BackendData (List Evergreen.V56.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V56.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V56.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V56.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V56.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V56.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V56.Bridge.BackendData (List Evergreen.V56.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V56.DimensionalModel.DimensionalModel
    , opened222 : Maybe Evergreen.V56.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V56.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V56.Utils.KeyCode
    , theme : Evergreen.V56.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V56.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V56.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V56.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V56.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V56.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V56.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V56.DimensionalModel.DimensionalModelRef
    | MouseEnteredErdCard Evergreen.V56.DuckDb.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V56.DuckDb.DuckDbRef Evergreen.V56.DuckDb.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V56.DuckDb.DuckDbRef Evergreen.V56.DuckDb.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V56.DuckDb.DuckDbRef
    | ClickedErdCardDropdownOption Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DuckDb.DuckDbRef (Evergreen.V56.DimensionalModel.KimballAssignment Evergreen.V56.DuckDb.DuckDbRef_ (List Evergreen.V56.DuckDb.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V56.DuckDb.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event
    | SvgViewBoxTransform SvgViewBoxTransformation
    | UserSelectedCursorMode CursorMode
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | TerminateDrags
    | ClearNodeHoverState
    | KimballNoop
    | KimballNoop_ Evergreen.V56.DuckDb.DuckDbRef
    | KimballNoop__ Int
