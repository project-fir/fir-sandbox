module Evergreen.V22.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V22.DuckDb
import Evergreen.V22.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V22.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V22.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V22.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V22.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V22.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V22.QueryBuilder.ColumnRef Evergreen.V22.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V22.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V22.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V22.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V22.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V22.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V22.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V22.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V22.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V22.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V22.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V22.QueryBuilder.ColumnRef Evergreen.V22.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V22.QueryBuilder.ColumnRef Evergreen.V22.QueryBuilder.Aggregation
