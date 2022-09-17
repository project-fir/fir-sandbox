module Evergreen.V10.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V10.DuckDb
import Evergreen.V10.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V10.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V10.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V10.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V10.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V10.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V10.QueryBuilder.ColumnRef Evergreen.V10.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V10.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V10.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V10.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V10.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V10.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V10.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V10.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V10.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V10.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V10.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V10.QueryBuilder.ColumnRef Evergreen.V10.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V10.QueryBuilder.ColumnRef Evergreen.V10.QueryBuilder.Aggregation
