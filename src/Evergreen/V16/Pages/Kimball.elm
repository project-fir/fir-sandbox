module Evergreen.V16.Pages.Kimball exposing (..)

import Browser.Dom
import Evergreen.V16.Bridge
import Evergreen.V16.DimensionalModel
import Evergreen.V16.DuckDb
import Html.Events.Extra.Mouse
import Http
import RemoteData


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
    | DragInitiated Evergreen.V16.DuckDb.DuckDbRef
    | Dragging Evergreen.V16.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event Evergreen.V16.DimensionalModel.TableRenderInfo


type alias Model =
    { duckDbRefs : RemoteData.WebData Evergreen.V16.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V16.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V16.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V16.DuckDb.DuckDbRef
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V16.Bridge.BackendData (List Evergreen.V16.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe Evergreen.V16.DimensionalModel.DimensionalModel
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V16.DimensionalModel.DimensionalModelRef)
    | GotDimensionalModel Evergreen.V16.DimensionalModel.DimensionalModel
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V16.DuckDb.DuckDbRefsResponse)
    | UserSelectedDimensionalModel Evergreen.V16.DimensionalModel.DimensionalModelRef
    | UserToggledDuckDbRefSelection Evergreen.V16.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V16.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V16.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V16.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V16.DimensionalModel.DimensionalModelRef
