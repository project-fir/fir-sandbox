module Evergreen.V62.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V62.Bridge
import Evergreen.V62.DimensionalModel
import Evergreen.V62.DuckDb
import Evergreen.V62.Ui
import Evergreen.V62.Utils
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
    | DragInitiated Evergreen.V62.DuckDb.DuckDbRef
    | Dragging Evergreen.V62.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V62.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V62.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V62.DuckDb.DuckDbColumnDescription Evergreen.V62.DuckDb.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V62.Bridge.BackendData (List Evergreen.V62.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V62.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V62.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V62.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V62.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V62.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V62.Bridge.BackendData (List Evergreen.V62.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V62.DimensionalModel.DimensionalModel
    , opened222 : Maybe Evergreen.V62.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V62.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V62.Utils.KeyCode
    , theme : Evergreen.V62.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V62.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V62.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V62.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V62.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V62.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V62.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V62.DimensionalModel.DimensionalModelRef
    | MouseEnteredErdCard Evergreen.V62.DuckDb.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V62.DuckDb.DuckDbRef Evergreen.V62.DuckDb.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V62.DuckDb.DuckDbRef Evergreen.V62.DuckDb.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V62.DuckDb.DuckDbRef
    | ClickedErdCardDropdownOption Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DuckDb.DuckDbRef (Evergreen.V62.DimensionalModel.KimballAssignment Evergreen.V62.DuckDb.DuckDbRef_ (List Evergreen.V62.DuckDb.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V62.DuckDb.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event
    | SvgViewBoxTransform SvgViewBoxTransformation
    | UserSelectedCursorMode CursorMode
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | TerminateDrags
    | ClearNodeHoverState
    | KimballNoop
    | KimballNoop_ Evergreen.V62.DuckDb.DuckDbRef
    | KimballNoop__ Int
