module Evergreen.V58.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V58.DuckDb
import Evergreen.V58.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V58.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V58.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V58.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V58.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V58.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V58.QueryBuilder.ColumnRef Evergreen.V58.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V58.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V58.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V58.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V58.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V58.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V58.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V58.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V58.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V58.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V58.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V58.QueryBuilder.ColumnRef Evergreen.V58.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V58.QueryBuilder.ColumnRef Evergreen.V58.QueryBuilder.Aggregation
