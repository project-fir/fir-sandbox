module Evergreen.V62.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V62.DuckDb
import Evergreen.V62.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V62.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V62.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V62.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V62.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V62.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V62.QueryBuilder.ColumnRef Evergreen.V62.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V62.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V62.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V62.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V62.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V62.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V62.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V62.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V62.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V62.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V62.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V62.QueryBuilder.ColumnRef Evergreen.V62.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V62.QueryBuilder.ColumnRef Evergreen.V62.QueryBuilder.Aggregation
