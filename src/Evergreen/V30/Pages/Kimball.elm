module Evergreen.V30.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V30.Bridge
import Evergreen.V30.DimensionalModel
import Evergreen.V30.DuckDb
import Evergreen.V30.Utils
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
    | DragInitiated Evergreen.V30.DuckDb.DuckDbRef
    | Dragging Evergreen.V30.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V30.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V30.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V30.DuckDb.DuckDbColumnDescription Evergreen.V30.DuckDb.DuckDbColumnDescription


type alias Model =
    { duckDbRefs : Evergreen.V30.Bridge.BackendData (List Evergreen.V30.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V30.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V30.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V30.DuckDb.DuckDbRef
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V30.Bridge.BackendData (List Evergreen.V30.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V30.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V30.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V30.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V30.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V30.Utils.KeyCode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V30.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V30.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V30.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V30.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V30.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V30.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V30.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V30.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V30.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V30.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V30.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedColumnRow Evergreen.V30.DuckDb.DuckDbColumnDescription
    | UserClickedKimballAssignment Evergreen.V30.DimensionalModel.DimensionalModelRef Evergreen.V30.DuckDb.DuckDbRef (Evergreen.V30.DimensionalModel.KimballAssignment Evergreen.V30.DuckDb.DuckDbRef_ (List Evergreen.V30.DuckDb.DuckDbColumnDescription))
    | KeyWentDown Evergreen.V30.Utils.KeyCode
    | KeyReleased Evergreen.V30.Utils.KeyCode
