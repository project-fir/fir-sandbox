module Evergreen.V36.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V36.Bridge
import Evergreen.V36.DimensionalModel
import Evergreen.V36.DuckDb
import Evergreen.V36.Utils
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
    | DragInitiated Evergreen.V36.DuckDb.DuckDbRef
    | Dragging Evergreen.V36.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V36.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V36.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V36.DuckDb.DuckDbColumnDescription Evergreen.V36.DuckDb.DuckDbColumnDescription


type alias Model =
    { duckDbRefs : Evergreen.V36.Bridge.BackendData (List Evergreen.V36.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V36.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V36.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V36.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V36.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V36.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V36.Bridge.BackendData (List Evergreen.V36.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V36.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V36.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V36.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V36.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V36.Utils.KeyCode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V36.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V36.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V36.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V36.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V36.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V36.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V36.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V36.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V36.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V36.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V36.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V36.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V36.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V36.DimensionalModel.DimensionalModelRef Evergreen.V36.DuckDb.DuckDbRef (Evergreen.V36.DimensionalModel.KimballAssignment Evergreen.V36.DuckDb.DuckDbRef_ (List Evergreen.V36.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V36.DuckDb.DuckDbColumnDescription
    | KeyWentDown Evergreen.V36.Utils.KeyCode
    | KeyReleased Evergreen.V36.Utils.KeyCode
