module Evergreen.V28.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V28.DuckDb
import Evergreen.V28.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V28.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V28.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V28.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V28.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V28.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V28.QueryBuilder.ColumnRef Evergreen.V28.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V28.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V28.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V28.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V28.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V28.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V28.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V28.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V28.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V28.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V28.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V28.QueryBuilder.ColumnRef Evergreen.V28.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V28.QueryBuilder.ColumnRef Evergreen.V28.QueryBuilder.Aggregation
