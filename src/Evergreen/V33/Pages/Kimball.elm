module Evergreen.V33.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V33.Bridge
import Evergreen.V33.DimensionalModel
import Evergreen.V33.DuckDb
import Evergreen.V33.Utils
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
    | DragInitiated Evergreen.V33.DuckDb.DuckDbRef
    | Dragging Evergreen.V33.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V33.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V33.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V33.DuckDb.DuckDbColumnDescription Evergreen.V33.DuckDb.DuckDbColumnDescription


type alias Model =
    { duckDbRefs : Evergreen.V33.Bridge.BackendData (List Evergreen.V33.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V33.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V33.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V33.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V33.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V33.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V33.Bridge.BackendData (List Evergreen.V33.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V33.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V33.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V33.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V33.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V33.Utils.KeyCode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V33.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V33.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V33.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V33.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V33.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V33.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V33.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V33.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V33.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V33.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V33.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V33.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V33.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V33.DimensionalModel.DimensionalModelRef Evergreen.V33.DuckDb.DuckDbRef (Evergreen.V33.DimensionalModel.KimballAssignment Evergreen.V33.DuckDb.DuckDbRef_ (List Evergreen.V33.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V33.DuckDb.DuckDbColumnDescription
    | KeyWentDown Evergreen.V33.Utils.KeyCode
    | KeyReleased Evergreen.V33.Utils.KeyCode
