module Evergreen.V13.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V13.DuckDb
import Evergreen.V13.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V13.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V13.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V13.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V13.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V13.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V13.QueryBuilder.ColumnRef Evergreen.V13.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V13.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V13.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V13.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V13.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V13.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V13.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V13.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V13.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V13.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V13.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V13.QueryBuilder.ColumnRef Evergreen.V13.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V13.QueryBuilder.ColumnRef Evergreen.V13.QueryBuilder.Aggregation
