module Evergreen.V54.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V54.DuckDb
import Evergreen.V54.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V54.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V54.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V54.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V54.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V54.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V54.QueryBuilder.ColumnRef Evergreen.V54.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V54.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V54.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V54.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V54.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V54.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V54.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V54.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V54.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V54.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V54.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V54.QueryBuilder.ColumnRef Evergreen.V54.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V54.QueryBuilder.ColumnRef Evergreen.V54.QueryBuilder.Aggregation
