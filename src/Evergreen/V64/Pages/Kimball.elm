module Evergreen.V64.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V64.Bridge
import Evergreen.V64.DimensionalModel
import Evergreen.V64.FirApi
import Evergreen.V64.Ui
import Evergreen.V64.Utils
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
    | DragInitiated Evergreen.V64.FirApi.DuckDbRef
    | Dragging Evergreen.V64.FirApi.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V64.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V64.FirApi.DuckDbColumnDescription
    | DestinationSelected Evergreen.V64.FirApi.DuckDbColumnDescription Evergreen.V64.FirApi.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V64.Bridge.BackendData (List Evergreen.V64.FirApi.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V64.FirApi.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V64.FirApi.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V64.FirApi.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V64.FirApi.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V64.FirApi.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V64.Bridge.BackendData (List Evergreen.V64.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V64.DimensionalModel.DimensionalModel
    , opened222 : Maybe Evergreen.V64.FirApi.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V64.FirApi.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V64.Utils.KeyCode
    , theme : Evergreen.V64.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V64.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V64.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V64.FirApi.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V64.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V64.FirApi.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V64.FirApi.DuckDbRef
    | UserMouseLeftTableRef
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V64.DimensionalModel.DimensionalModelRef
    | MouseEnteredErdCard Evergreen.V64.FirApi.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V64.FirApi.DuckDbRef Evergreen.V64.FirApi.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V64.FirApi.DuckDbRef Evergreen.V64.FirApi.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V64.FirApi.DuckDbRef
    | ClickedErdCardDropdownOption Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.FirApi.DuckDbRef (Evergreen.V64.DimensionalModel.KimballAssignment Evergreen.V64.FirApi.DuckDbRef_ (List Evergreen.V64.FirApi.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V64.FirApi.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event
    | SvgViewBoxTransform SvgViewBoxTransformation
    | UserSelectedCursorMode CursorMode
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | TerminateDrags
    | ClearNodeHoverState
    | KimballNoop
    | KimballNoop_ Evergreen.V64.FirApi.DuckDbRef
    | KimballNoop__ Int
