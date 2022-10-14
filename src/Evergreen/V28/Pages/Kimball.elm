module Evergreen.V28.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V28.Bridge
import Evergreen.V28.DimensionalModel
import Evergreen.V28.DuckDb
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
    | DragInitiated Evergreen.V28.DuckDb.DuckDbRef
    | Dragging Evergreen.V28.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V28.DimensionalModel.CardRenderInfo


type alias Model =
    { duckDbRefs : Evergreen.V28.Bridge.BackendData (List Evergreen.V28.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V28.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V28.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V28.DuckDb.DuckDbRef
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V28.Bridge.BackendData (List Evergreen.V28.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V28.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V28.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V28.DuckDb.DuckDbRef
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V28.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V28.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V28.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V28.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V28.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V28.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V28.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V28.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V28.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V28.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V28.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V28.DimensionalModel.DimensionalModelRef Evergreen.V28.DuckDb.DuckDbRef (Evergreen.V28.DimensionalModel.KimballAssignment Evergreen.V28.DuckDb.DuckDbRef_ (List Evergreen.V28.DuckDb.DuckDbColumnDescription))
