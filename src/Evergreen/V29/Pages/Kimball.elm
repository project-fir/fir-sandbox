module Evergreen.V29.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V29.Bridge
import Evergreen.V29.DimensionalModel
import Evergreen.V29.DuckDb
import Evergreen.V29.Utils
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
    | DragInitiated Evergreen.V29.DuckDb.DuckDbRef
    | Dragging Evergreen.V29.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V29.DimensionalModel.CardRenderInfo


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected Evergreen.V29.DuckDb.DuckDbColumnDescription
    | DestinationSelected Evergreen.V29.DuckDb.DuckDbColumnDescription Evergreen.V29.DuckDb.DuckDbColumnDescription


type alias Model =
    { duckDbRefs : Evergreen.V29.Bridge.BackendData (List Evergreen.V29.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V29.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V29.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V29.DuckDb.DuckDbRef
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V29.Bridge.BackendData (List Evergreen.V29.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V29.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V29.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V29.DuckDb.DuckDbRef
    , inspectedColumn : Maybe Evergreen.V29.DuckDb.DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set.Set Evergreen.V29.Utils.KeyCode
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V29.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V29.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V29.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V29.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V29.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V29.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V29.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V29.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V29.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V29.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V29.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedColumnRow Evergreen.V29.DuckDb.DuckDbColumnDescription
    | UserClickedKimballAssignment Evergreen.V29.DimensionalModel.DimensionalModelRef Evergreen.V29.DuckDb.DuckDbRef (Evergreen.V29.DimensionalModel.KimballAssignment Evergreen.V29.DuckDb.DuckDbRef_ (List Evergreen.V29.DuckDb.DuckDbColumnDescription))
    | KeyWentDown Evergreen.V29.Utils.KeyCode
    | KeyReleased Evergreen.V29.Utils.KeyCode
