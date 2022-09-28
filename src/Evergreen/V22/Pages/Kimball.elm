module Evergreen.V22.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V22.Bridge
import Evergreen.V22.DimensionalModel
import Evergreen.V22.DuckDb
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
    | DragInitiated Evergreen.V22.DuckDb.DuckDbRef
    | Dragging Evergreen.V22.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V22.DimensionalModel.CardRenderInfo


type alias Model =
    { duckDbRefs : Evergreen.V22.Bridge.BackendData (List Evergreen.V22.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V22.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V22.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V22.DuckDb.DuckDbRef
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V22.Bridge.BackendData (List Evergreen.V22.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V22.DimensionalModel.DimensionalModel
    , pairingAlgoResult : Maybe Evergreen.V22.DimensionalModel.NaivePairingStrategyResult
    , dropdownState : Maybe Evergreen.V22.DuckDb.DuckDbRef
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V22.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V22.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V22.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V22.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V22.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V22.DuckDb.DuckDbRef
    | UserClickedAttemptPairing Evergreen.V22.DimensionalModel.DimensionalModelRef
    | UserToggledCardDropDown Evergreen.V22.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V22.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V22.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V22.DimensionalModel.DimensionalModelRef
    | NoopKimball
    | UserClickedKimballAssignment Evergreen.V22.DimensionalModel.DimensionalModelRef Evergreen.V22.DuckDb.DuckDbRef (Evergreen.V22.DimensionalModel.KimballAssignment Evergreen.V22.DuckDb.DuckDbRef_ (List Evergreen.V22.DuckDb.DuckDbColumnDescription))
