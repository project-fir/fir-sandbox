module Evergreen.V37.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V37.Bridge
import Evergreen.V37.DimensionalModel
import Evergreen.V37.DuckDb
import Evergreen.V37.Utils
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
    | DragInitiated Evergreen.V37.DuckDb.DuckDbRef
    | Dragging Evergreen.V37.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V37.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V37.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V37.DuckDb.DuckDbColumnDescription Evergreen.V37.DuckDb.DuckDbColumnDescription


type alias Model =
    { duckDbRefs : Evergreen.V37.Bridge.BackendData (List Evergreen.V37.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V37.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V37.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V37.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V37.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V37.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V37.Bridge.BackendData (List Evergreen.V37.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V37.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V37.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V37.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V37.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V37.Utils.KeyCode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V37.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V37.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V37.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V37.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V37.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V37.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V37.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V37.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V37.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V37.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V37.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V37.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V37.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V37.DimensionalModel.DimensionalModelRef Evergreen.V37.DuckDb.DuckDbRef (Evergreen.V37.DimensionalModel.KimballAssignment Evergreen.V37.DuckDb.DuckDbRef_ (List Evergreen.V37.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V37.DuckDb.DuckDbColumnDescription
    | KeyWentDown Evergreen.V37.Utils.KeyCode
    | KeyReleased Evergreen.V37.Utils.KeyCode
