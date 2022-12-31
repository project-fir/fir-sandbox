module Evergreen.V63.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V63.Bridge
import Evergreen.V63.DimensionalModel
import Evergreen.V63.FirApi
import Evergreen.V63.Ui
import Evergreen.V63.Utils
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
    | DragInitiated Evergreen.V63.FirApi.DuckDbRef
    | Dragging Evergreen.V63.FirApi.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V63.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V63.FirApi.DuckDbColumnDescription
    | DestinationSelected Evergreen.V63.FirApi.DuckDbColumnDescription Evergreen.V63.FirApi.DuckDbColumnDescription


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


type alias Model =
    { duckDbRefs : Evergreen.V63.Bridge.BackendData (List Evergreen.V63.FirApi.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V63.FirApi.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V63.FirApi.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V63.FirApi.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V63.FirApi.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V63.FirApi.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V63.Bridge.BackendData (List Evergreen.V63.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V63.DimensionalModel.DimensionalModel
    , opened222 : Maybe Evergreen.V63.FirApi.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V63.FirApi.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V63.Utils.KeyCode
    , theme : Evergreen.V63.Ui.ColorTheme
    , cursorMode : CursorMode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V63.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V63.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V63.FirApi.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V63.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V63.FirApi.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V63.FirApi.DuckDbRef
    | UserMouseLeftTableRef
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V63.DimensionalModel.DimensionalModelRef
    | MouseEnteredErdCard Evergreen.V63.FirApi.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V63.FirApi.DuckDbRef Evergreen.V63.FirApi.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V63.FirApi.DuckDbRef Evergreen.V63.FirApi.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V63.FirApi.DuckDbRef
    | ClickedErdCardDropdownOption Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.FirApi.DuckDbRef (Evergreen.V63.DimensionalModel.KimballAssignment Evergreen.V63.FirApi.DuckDbRef_ (List Evergreen.V63.FirApi.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V63.FirApi.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event
    | SvgViewBoxTransform SvgViewBoxTransformation
    | UserSelectedCursorMode CursorMode
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | TerminateDrags
    | ClearNodeHoverState
    | KimballNoop
    | KimballNoop_ Evergreen.V63.FirApi.DuckDbRef
    | KimballNoop__ Int
