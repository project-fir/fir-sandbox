module Evergreen.V61.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V61.DuckDb
import Evergreen.V61.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V61.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V61.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V61.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V61.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V61.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V61.QueryBuilder.ColumnRef Evergreen.V61.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V61.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V61.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V61.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V61.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V61.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V61.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V61.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V61.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V61.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V61.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V61.QueryBuilder.ColumnRef Evergreen.V61.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V61.QueryBuilder.ColumnRef Evergreen.V61.QueryBuilder.Aggregation
