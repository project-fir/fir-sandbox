module Evergreen.V29.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V29.DuckDb
import Evergreen.V29.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V29.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V29.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V29.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V29.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V29.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V29.QueryBuilder.ColumnRef Evergreen.V29.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V29.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V29.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V29.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V29.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V29.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V29.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V29.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V29.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V29.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V29.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V29.QueryBuilder.ColumnRef Evergreen.V29.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V29.QueryBuilder.ColumnRef Evergreen.V29.QueryBuilder.Aggregation
