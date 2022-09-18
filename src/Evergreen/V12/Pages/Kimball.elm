module Evergreen.V12.Pages.Kimball exposing (..)

import Dict
import Evergreen.V12.DuckDb
import Html.Events.Extra.Mouse
import Http
import RemoteData


type Table
    = Fact Evergreen.V12.DuckDb.DuckDbRef_ (List Evergreen.V12.DuckDb.DuckDbColumnDescription)
    | Dim Evergreen.V12.DuckDb.DuckDbRef_ (List Evergreen.V12.DuckDb.DuckDbColumnDescription)


type alias RefString =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V12.DuckDb.DuckDbRef
    }


type alias SvgViewBoxDimensions =
    { width : Float
    , height : Float
    , viewBoxXMin : Float
    , viewBoxYMin : Float
    , viewBoxWidth : Float
    , viewBoxHeight : Float
    }


type DragState
    = Idle
    | DragInitiated Evergreen.V12.DuckDb.DuckDbRef
    | Dragging Evergreen.V12.DuckDb.DuckDbRef (Maybe Html.Events.Extra.Mouse.Event) Html.Events.Extra.Mouse.Event TableRenderInfo


type alias Model =
    { duckDbRefs : RemoteData.WebData Evergreen.V12.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V12.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V12.DuckDb.DuckDbRef
    , hoveredOnNodeTitle : Maybe Evergreen.V12.DuckDb.DuckDbRef
    , tables : List Table
    , tableRenderInfo : Dict.Dict RefString TableRenderInfo
    , svgViewBox : SvgViewBoxDimensions
    , dragState : DragState
    , mouseEvent : Maybe Html.Events.Extra.Mouse.Event
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float
    | Reset


type Msg
    = FetchTableRefs
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V12.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V12.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V12.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V12.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag Evergreen.V12.DuckDb.DuckDbRef
    | DraggedAt Html.Events.Extra.Mouse.Event
    | DragStoppedAt Html.Events.Extra.Mouse.Event
    | TerminateDrags
