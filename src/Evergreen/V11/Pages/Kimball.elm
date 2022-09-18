module Evergreen.V11.Pages.Kimball exposing (..)

import Dict
import Evergreen.V11.DuckDb
import Http
import RemoteData


type Table
    = Fact Evergreen.V11.DuckDb.DuckDbRef_ (List Evergreen.V11.DuckDb.DuckDbColumnDescription)
    | Dim Evergreen.V11.DuckDb.DuckDbRef_ (List Evergreen.V11.DuckDb.DuckDbColumnDescription)


type alias RefString =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V11.DuckDb.DuckDbRef
    }


type alias SvgViewBoxDimensions =
    { width : Float
    , height : Float
    , viewBoxXmin : Float
    , viewBoxYmin : Float
    , viewBoxWidth : Float
    , viewBoxHeight : Float
    }


type alias Model =
    { duckDbRefs : RemoteData.WebData Evergreen.V11.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V11.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V11.DuckDb.DuckDbRef
    , hoveredOnNodeTitle : Maybe Evergreen.V11.DuckDb.DuckDbRef
    , tables : List Table
    , tableRenderInfo : Dict.Dict RefString TableRenderInfo
    , svgViewBox : SvgViewBoxDimensions
    }


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float
    | Reset


type Msg
    = FetchTableRefs
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V11.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V11.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V11.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V11.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
