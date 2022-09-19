module Evergreen.V15.Pages.Kimball exposing (..)

import Browser.Dom
import Dict
import Evergreen.V15.Bridge
import Evergreen.V15.DimensionalModel
import Evergreen.V15.DuckDb
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


type Table
    = Fact Evergreen.V15.DuckDb.DuckDbRef_ (List Evergreen.V15.DuckDb.DuckDbColumnDescription)
    | Dim Evergreen.V15.DuckDb.DuckDbRef_ (List Evergreen.V15.DuckDb.DuckDbColumnDescription)


type alias RefString =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V15.DuckDb.DuckDbRef
    }


type DragState
    = Idle
    | DragInitiated Evergreen.V15.DuckDb.DuckDbRef
    | Dragging Evergreen.V15.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event TableRenderInfo


type alias Model =
    { duckDbRefs : RemoteData.WebData Evergreen.V15.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V15.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V15.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V15.DuckDb.DuckDbRef
    , tables : List Table
    , tableRenderInfo : Dict.Dict RefString TableRenderInfo
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : Evergreen.V15.Bridge.BackendData (List Evergreen.V15.DimensionalModel.DimensionalModelRef)
    , proposedNewModelName : String
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List Evergreen.V15.DimensionalModel.DimensionalModelRef)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V15.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V15.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V15.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V15.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V15.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel Evergreen.V15.DimensionalModel.DimensionalModelRef
