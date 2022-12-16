module Evergreen.V48.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V48.DuckDb
import Evergreen.V48.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V48.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V48.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V48.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V48.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V48.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V48.QueryBuilder.ColumnRef Evergreen.V48.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V48.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V48.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V48.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V48.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V48.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V48.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V48.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V48.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V48.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V48.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V48.QueryBuilder.ColumnRef Evergreen.V48.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V48.QueryBuilder.ColumnRef Evergreen.V48.QueryBuilder.Aggregation
