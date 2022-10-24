module Evergreen.V33.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V33.DuckDb
import Evergreen.V33.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V33.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V33.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V33.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V33.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V33.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V33.QueryBuilder.ColumnRef Evergreen.V33.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V33.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V33.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V33.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V33.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V33.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V33.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V33.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V33.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V33.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V33.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V33.QueryBuilder.ColumnRef Evergreen.V33.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V33.QueryBuilder.ColumnRef Evergreen.V33.QueryBuilder.Aggregation
