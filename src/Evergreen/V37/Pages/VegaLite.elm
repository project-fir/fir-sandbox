module Evergreen.V37.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V37.DuckDb
import Evergreen.V37.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V37.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V37.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V37.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V37.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V37.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V37.QueryBuilder.ColumnRef Evergreen.V37.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V37.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V37.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V37.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V37.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V37.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V37.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V37.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V37.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V37.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V37.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V37.QueryBuilder.ColumnRef Evergreen.V37.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V37.QueryBuilder.ColumnRef Evergreen.V37.QueryBuilder.Aggregation
