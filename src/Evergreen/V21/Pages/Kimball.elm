module Evergreen.V21.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V21.Bridge
import Evergreen.V21.DimensionalModel
import Evergreen.V21.DuckDb
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
    | DragInitiated Evergreen.V21.DuckDb.DuckDbRef
    | Dragging Evergreen.V21.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V21.DimensionalModel.CardRenderInfo


type alias Model =
    { duckDbRefs : Evergreen.V21.Bridge.BackendData (List Evergreen.V21.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V21.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V21.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V21.DuckDb.DuckDbRef
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V21.Bridge.BackendData (List Evergreen.V21.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V21.DimensionalModel.DimensionalModel
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V21.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V21.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V21.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V21.DimensionalModel.DimensionalModelRef
    | UserClickedDuckDbRef Evergreen.V21.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V21.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V21.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V21.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V21.DimensionalModel.DimensionalModelRef
