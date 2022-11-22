module Evergreen.V36.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V36.DuckDb
import Evergreen.V36.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V36.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V36.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V36.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V36.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V36.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V36.QueryBuilder.ColumnRef Evergreen.V36.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V36.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V36.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V36.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V36.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V36.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V36.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V36.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V36.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V36.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V36.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V36.QueryBuilder.ColumnRef Evergreen.V36.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V36.QueryBuilder.ColumnRef Evergreen.V36.QueryBuilder.Aggregation
