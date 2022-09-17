module Evergreen.V10.Pages.Kimball exposing (..)

import Dict
import Evergreen.V10.DuckDb
import Http
import RemoteData


type Table
    = Fact Evergreen.V10.DuckDb.DuckDbRef_ (List Evergreen.V10.DuckDb.DuckDbColumnDescription)
    | Dim Evergreen.V10.DuckDb.DuckDbRef_ (List Evergreen.V10.DuckDb.DuckDbColumnDescription)


type alias RefString =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V10.DuckDb.DuckDbRef
    }


type alias Model =
    { duckDbRefs : RemoteData.WebData Evergreen.V10.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V10.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V10.DuckDb.DuckDbRef
    , hoveredOnNodeTitle : Maybe Evergreen.V10.DuckDb.DuckDbRef
    , tables : List Table
    , tableRenderInfo : Dict.Dict RefString TableRenderInfo
    }


type Msg
    = FetchTableRefs
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V10.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V10.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V10.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V10.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
