module Evergreen.V7.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V7.DuckDb
import Evergreen.V7.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V7.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V7.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V7.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V7.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V7.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V7.QueryBuilder.ColumnRef Evergreen.V7.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V7.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V7.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V7.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V7.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V7.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V7.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V7.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V7.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V7.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V7.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V7.QueryBuilder.ColumnRef Evergreen.V7.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V7.QueryBuilder.ColumnRef Evergreen.V7.QueryBuilder.Aggregation
