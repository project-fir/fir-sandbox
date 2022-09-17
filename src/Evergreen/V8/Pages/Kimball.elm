module Evergreen.V8.Pages.Kimball exposing (..)

import Dict
import Evergreen.V8.DuckDb
import Http
import RemoteData


type Table
    = Fact Evergreen.V8.DuckDb.DuckDbRef_ (List Evergreen.V8.DuckDb.DuckDbColumnDescription)
    | Dim Evergreen.V8.DuckDb.DuckDbRef_ (List Evergreen.V8.DuckDb.DuckDbColumnDescription)


type alias RefString =
    String


type alias PositionPx =
    { x : Float
    , y : Float
    }


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : Evergreen.V8.DuckDb.DuckDbRef
    }


type alias Model =
    { duckDbRefs : RemoteData.WebData Evergreen.V8.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V8.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V8.DuckDb.DuckDbRef
    , hoveredOnNodeTitle : Maybe Evergreen.V8.DuckDb.DuckDbRef
    , tables : List Table
    , tableRenderInfo : Dict.Dict RefString TableRenderInfo
    }


type Msg
    = FetchTableRefs
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V8.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V8.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V8.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar Evergreen.V8.DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
