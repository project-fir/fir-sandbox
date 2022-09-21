module Evergreen.V18.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V18.Bridge
import Evergreen.V18.DimensionalModel
import Evergreen.V18.DuckDb
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
    | DragInitiated Evergreen.V18.DuckDb.DuckDbRef
    | Dragging Evergreen.V18.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V18.DimensionalModel.TableRenderInfo


type alias Model =
    { duckDbRefs : Evergreen.V18.Bridge.BackendData (List Evergreen.V18.DuckDb.DuckDbRef)
    , selectedTableRef : Maybe Evergreen.V18.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V18.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V18.DuckDb.DuckDbRef
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V18.Bridge.BackendData (List Evergreen.V18.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V18.DimensionalModel.DimensionalModel
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V18.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V18.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (List Evergreen.V18.DuckDb.DuckDbRef)
    | UserSelectedDimensionalModel Evergreen.V18.DimensionalModel.DimensionalModelRef
    | UserToggledDuckDbRefSelection Evergreen.V18.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V18.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V18.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V18.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V18.DimensionalModel.DimensionalModelRef
