module Evergreen.V50.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V50.DuckDb
import Evergreen.V50.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V50.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V50.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V50.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V50.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V50.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V50.QueryBuilder.ColumnRef Evergreen.V50.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V50.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V50.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V50.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V50.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V50.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V50.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V50.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V50.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V50.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V50.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V50.QueryBuilder.ColumnRef Evergreen.V50.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V50.QueryBuilder.ColumnRef Evergreen.V50.QueryBuilder.Aggregation
