module Evergreen.V61.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V61.Bridge
import Evergreen.V61.DimensionalModel
import Evergreen.V61.DuckDb
import Evergreen.V61.Ui
import Evergreen.V61.Utils
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
    | DragInitiated Evergreen.V61.DuckDb.DuckDbRef
    | Dragging Evergreen.V61.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V61.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V61.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V61.DuckDb.DuckDbColumnDescription Evergreen.V61.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V61.Bridge.BackendData (List Evergreen.V61.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V61.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V61.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V61.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V61.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V61.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V61.Bridge.BackendData (List Evergreen.V61.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V61.DimensionalModel.DimensionalModel
    , opened222 : Maybe Evergreen.V61.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V61.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V61.Utils.KeyCode
    , theme : Evergreen.V61.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V61.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V61.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V61.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V61.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V61.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V61.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V61.DimensionalModel.DimensionalModelRef
    | MouseEnteredErdCard Evergreen.V61.DuckDb.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V61.DuckDb.DuckDbRef Evergreen.V61.DuckDb.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V61.DuckDb.DuckDbRef Evergreen.V61.DuckDb.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V61.DuckDb.DuckDbRef
    | ClickedErdCardDropdownOption Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DuckDb.DuckDbRef (Evergreen.V61.DimensionalModel.KimballAssignment Evergreen.V61.DuckDb.DuckDbRef_ (List Evergreen.V61.DuckDb.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V61.DuckDb.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event
    | SvgViewBoxTransform SvgViewBoxTransformation
    | UserSelectedCursorMode CursorMode
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | TerminateDrags
    | ClearNodeHoverState
    | KimballNoop
    | KimballNoop_ Evergreen.V61.DuckDb.DuckDbRef
    | KimballNoop__ Int
