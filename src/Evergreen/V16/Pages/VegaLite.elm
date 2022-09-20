module Evergreen.V16.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V16.DuckDb
import Evergreen.V16.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V16.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V16.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V16.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V16.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V16.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V16.QueryBuilder.ColumnRef Evergreen.V16.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V16.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V16.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V16.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V16.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V16.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V16.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V16.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V16.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V16.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V16.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V16.QueryBuilder.ColumnRef Evergreen.V16.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V16.QueryBuilder.ColumnRef Evergreen.V16.QueryBuilder.Aggregation
