module Evergreen.V41.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V41.DuckDb
import Evergreen.V41.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V41.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V41.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V41.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V41.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V41.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V41.QueryBuilder.ColumnRef Evergreen.V41.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V41.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V41.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V41.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V41.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V41.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V41.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V41.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V41.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V41.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V41.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V41.QueryBuilder.ColumnRef Evergreen.V41.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V41.QueryBuilder.ColumnRef Evergreen.V41.QueryBuilder.Aggregation
