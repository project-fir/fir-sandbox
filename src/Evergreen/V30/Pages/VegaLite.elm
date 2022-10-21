module Evergreen.V30.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V30.DuckDb
import Evergreen.V30.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V30.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V30.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V30.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V30.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V30.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V30.QueryBuilder.ColumnRef Evergreen.V30.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V30.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V30.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V30.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V30.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V30.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V30.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V30.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V30.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V30.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V30.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V30.QueryBuilder.ColumnRef Evergreen.V30.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V30.QueryBuilder.ColumnRef Evergreen.V30.QueryBuilder.Aggregation
