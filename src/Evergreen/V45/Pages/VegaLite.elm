module Evergreen.V45.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V45.DuckDb
import Evergreen.V45.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V45.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V45.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V45.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V45.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V45.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V45.QueryBuilder.ColumnRef Evergreen.V45.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V45.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V45.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V45.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V45.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V45.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V45.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V45.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V45.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V45.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V45.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V45.QueryBuilder.ColumnRef Evergreen.V45.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V45.QueryBuilder.ColumnRef Evergreen.V45.QueryBuilder.Aggregation
