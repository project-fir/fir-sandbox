module Evergreen.V26.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V26.Bridge
import Evergreen.V26.DimensionalModel
import Evergreen.V26.DuckDb
import Html.Events.Extra.Mouse


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
    | DragInitiated Evergreen.V26.DuckDb.DuckDbRef
    | Dragging Evergreen.V26.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V26.DimensionalModel.CardRenderInfo


type alias Model =
    { duckDbRefs : Evergreen.V26.Bridge.BackendData (List Evergreen.V26.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V26.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V26.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V26.DuckDb.DuckDbRef
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V26.Bridge.BackendData (List Evergreen.V26.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V26.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V26.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V26.DuckDb.DuckDbRef
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V26.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V26.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V26.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V26.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V26.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V26.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V26.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V26.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V26.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V26.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V26.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V26.DimensionalModel.DimensionalModelRef Evergreen.V26.DuckDb.DuckDbRef (Evergreen.V26.DimensionalModel.KimballAssignment Evergreen.V26.DuckDb.DuckDbRef_ (List Evergreen.V26.DuckDb.DuckDbColumnDescription))
