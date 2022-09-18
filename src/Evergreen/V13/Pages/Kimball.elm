module Evergreen.V13.Pages.Kimball exposing (..)

import Browser.Dom
import Dict
import Evergreen.V13.DuckDb
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
    = Fact Evergreen.V13.DuckDb.DuckDbRef_ (List Evergreen.V13.DuckDb.DuckDbColumnDescription)
    | Dim Evergreen.V13.DuckDb.DuckDbRef_ (List Evergreen.V13.DuckDb.DuckDbColumnDescription)


type alias RefString =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V13.DuckDb.DuckDbRef
    }


type DragState
    = Idle
    | DragInitiated Evergreen.V13.DuckDb.DuckDbRef
    | Dragging Evergreen.V13.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event TableRenderInfo


type alias Model =
    { duckDbRefs : RemoteData.WebData Evergreen.V13.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V13.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V13.DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe Evergreen.V13.DuckDb.DuckDbRef
    , tables : List Table
    , tableRenderInfo : Dict.Dict RefString TableRenderInfo
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    , viewPort : Maybe Browser.Dom.Viewport
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type Msg
    = FetchTableRefs
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V13.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V13.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V13.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V13.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V13.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
