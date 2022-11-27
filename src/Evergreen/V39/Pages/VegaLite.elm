module Evergreen.V39.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V39.DuckDb
import Evergreen.V39.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V39.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V39.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V39.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V39.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V39.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V39.QueryBuilder.ColumnRef Evergreen.V39.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V39.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V39.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V39.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V39.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V39.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V39.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V39.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V39.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V39.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V39.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V39.QueryBuilder.ColumnRef Evergreen.V39.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V39.QueryBuilder.ColumnRef Evergreen.V39.QueryBuilder.Aggregation
