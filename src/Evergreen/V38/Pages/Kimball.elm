module Evergreen.V38.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V38.Bridge
import Evergreen.V38.DimensionalModel
import Evergreen.V38.DuckDb
import Evergreen.V38.Utils
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
    | DragInitiated Evergreen.V38.DuckDb.DuckDbRef
    | Dragging Evergreen.V38.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V38.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V38.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V38.DuckDb.DuckDbColumnDescription Evergreen.V38.DuckDb.DuckDbColumnDescription


type alias Model =
    { duckDbRefs : Evergreen.V38.Bridge.BackendData (List Evergreen.V38.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V38.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V38.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V38.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V38.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V38.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V38.Bridge.BackendData (List Evergreen.V38.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V38.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V38.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V38.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V38.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V38.Utils.KeyCode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V38.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V38.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V38.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V38.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V38.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V38.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V38.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V38.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V38.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V38.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V38.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V38.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V38.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V38.DimensionalModel.DimensionalModelRef Evergreen.V38.DuckDb.DuckDbRef (Evergreen.V38.DimensionalModel.KimballAssignment Evergreen.V38.DuckDb.DuckDbRef_ (List Evergreen.V38.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V38.DuckDb.DuckDbColumnDescription
    | KeyWentDown Evergreen.V38.Utils.KeyCode
    | KeyReleased Evergreen.V38.Utils.KeyCode
