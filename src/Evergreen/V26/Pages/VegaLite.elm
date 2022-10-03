module Evergreen.V26.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V26.DuckDb
import Evergreen.V26.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V26.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V26.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V26.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V26.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V26.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V26.QueryBuilder.ColumnRef Evergreen.V26.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V26.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V26.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V26.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V26.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V26.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V26.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V26.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V26.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V26.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V26.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V26.QueryBuilder.ColumnRef Evergreen.V26.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V26.QueryBuilder.ColumnRef Evergreen.V26.QueryBuilder.Aggregation
