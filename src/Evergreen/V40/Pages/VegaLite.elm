module Evergreen.V40.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V40.DuckDb
import Evergreen.V40.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V40.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V40.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V40.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V40.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V40.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V40.QueryBuilder.ColumnRef Evergreen.V40.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V40.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V40.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V40.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V40.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V40.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V40.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V40.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V40.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V40.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V40.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V40.QueryBuilder.ColumnRef Evergreen.V40.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V40.QueryBuilder.ColumnRef Evergreen.V40.QueryBuilder.Aggregation
