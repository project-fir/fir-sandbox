module Evergreen.V8.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V8.DuckDb
import Evergreen.V8.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V8.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V8.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V8.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V8.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V8.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V8.QueryBuilder.ColumnRef Evergreen.V8.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V8.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V8.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V8.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V8.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V8.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V8.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V8.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V8.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V8.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V8.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V8.QueryBuilder.ColumnRef Evergreen.V8.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V8.QueryBuilder.ColumnRef Evergreen.V8.QueryBuilder.Aggregation
