module Evergreen.V52.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V52.DuckDb
import Evergreen.V52.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V52.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V52.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V52.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V52.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V52.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V52.QueryBuilder.ColumnRef Evergreen.V52.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V52.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V52.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V52.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V52.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V52.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V52.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V52.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V52.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V52.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V52.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V52.QueryBuilder.ColumnRef Evergreen.V52.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V52.QueryBuilder.ColumnRef Evergreen.V52.QueryBuilder.Aggregation
