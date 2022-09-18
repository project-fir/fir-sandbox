module Evergreen.V12.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V12.DuckDb
import Evergreen.V12.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V12.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V12.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V12.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V12.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V12.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V12.QueryBuilder.ColumnRef Evergreen.V12.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V12.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V12.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V12.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V12.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V12.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V12.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V12.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V12.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V12.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V12.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V12.QueryBuilder.ColumnRef Evergreen.V12.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V12.QueryBuilder.ColumnRef Evergreen.V12.QueryBuilder.Aggregation
