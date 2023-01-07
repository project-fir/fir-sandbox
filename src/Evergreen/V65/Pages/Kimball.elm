module Evergreen.V65.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V65.Bridge
import Evergreen.V65.DimensionalModel
import Evergreen.V65.FirApi
import Evergreen.V65.Ui
import Evergreen.V65.Utils
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
    | DragInitiated Evergreen.V65.FirApi.DuckDbRef
    | Dragging Evergreen.V65.FirApi.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V65.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V65.FirApi.DuckDbColumnDescription
    | DestinationSelected Evergreen.V65.FirApi.DuckDbColumnDescription Evergreen.V65.FirApi.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V65.Bridge.BackendData (List Evergreen.V65.FirApi.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V65.FirApi.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V65.FirApi.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V65.FirApi.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V65.FirApi.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V65.FirApi.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V65.Bridge.BackendData (List Evergreen.V65.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V65.DimensionalModel.DimensionalModel
    , opened222 : Maybe Evergreen.V65.FirApi.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V65.FirApi.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V65.Utils.KeyCode
    , theme : Evergreen.V65.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V65.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V65.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V65.FirApi.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V65.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V65.FirApi.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V65.FirApi.DuckDbRef
    | UserMouseLeftTableRef
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V65.DimensionalModel.DimensionalModelRef
    | MouseEnteredErdCard Evergreen.V65.FirApi.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V65.FirApi.DuckDbRef Evergreen.V65.FirApi.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V65.FirApi.DuckDbRef Evergreen.V65.FirApi.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V65.FirApi.DuckDbRef
    | ClickedErdCardDropdownOption Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.FirApi.DuckDbRef (Evergreen.V65.DimensionalModel.KimballAssignment Evergreen.V65.FirApi.DuckDbRef_ (List Evergreen.V65.FirApi.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V65.FirApi.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event
    | SvgViewBoxTransform SvgViewBoxTransformation
    | UserSelectedCursorMode CursorMode
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | TerminateDrags
    | ClearNodeHoverState
    | KimballNoop
    | KimballNoop_ Evergreen.V65.FirApi.DuckDbRef
    | KimballNoop__ Int
