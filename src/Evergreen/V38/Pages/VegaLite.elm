module Evergreen.V38.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V38.DuckDb
import Evergreen.V38.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V38.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V38.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V38.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V38.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V38.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V38.QueryBuilder.ColumnRef Evergreen.V38.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V38.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V38.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V38.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V38.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V38.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V38.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V38.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V38.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V38.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V38.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V38.QueryBuilder.ColumnRef Evergreen.V38.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V38.QueryBuilder.ColumnRef Evergreen.V38.QueryBuilder.Aggregation
