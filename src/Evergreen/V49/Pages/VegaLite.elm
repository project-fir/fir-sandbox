module Evergreen.V49.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V49.DuckDb
import Evergreen.V49.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V49.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V49.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V49.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V49.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V49.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V49.QueryBuilder.ColumnRef Evergreen.V49.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V49.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V49.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V49.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V49.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V49.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V49.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V49.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V49.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V49.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V49.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V49.QueryBuilder.ColumnRef Evergreen.V49.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V49.QueryBuilder.ColumnRef Evergreen.V49.QueryBuilder.Aggregation
