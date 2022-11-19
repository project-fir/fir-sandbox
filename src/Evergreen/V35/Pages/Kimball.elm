module Evergreen.V35.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V35.Bridge
import Evergreen.V35.DimensionalModel
import Evergreen.V35.DuckDb
import Evergreen.V35.Utils
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
    | DragInitiated Evergreen.V35.DuckDb.DuckDbRef
    | Dragging Evergreen.V35.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V35.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V35.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V35.DuckDb.DuckDbColumnDescription Evergreen.V35.DuckDb.DuckDbColumnDescription


type alias Model =
    { duckDbRefs : Evergreen.V35.Bridge.BackendData (List Evergreen.V35.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V35.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V35.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V35.DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe Evergreen.V35.DuckDb.DuckDbColumnDescription
    , partialEdgeInProgress : Maybe Evergreen.V35.DuckDb.DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V35.Bridge.BackendData (List Evergreen.V35.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V35.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V35.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V35.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V35.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V35.Utils.KeyCode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V35.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V35.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V35.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V35.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V35.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V35.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V35.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V35.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V35.DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow Evergreen.V35.DuckDb.DuckDbColumnDescription
    | UserClickedColumnRow Evergreen.V35.DuckDb.DuckDbColumnDescription
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V35.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V35.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V35.DimensionalModel.DimensionalModelRef Evergreen.V35.DuckDb.DuckDbRef (Evergreen.V35.DimensionalModel.KimballAssignment Evergreen.V35.DuckDb.DuckDbRef_ (List Evergreen.V35.DuckDb.DuckDbColumnDescription))
    | UserClickedNub Evergreen.V35.DuckDb.DuckDbColumnDescription
    | KeyWentDown Evergreen.V35.Utils.KeyCode
    | KeyReleased Evergreen.V35.Utils.KeyCode
