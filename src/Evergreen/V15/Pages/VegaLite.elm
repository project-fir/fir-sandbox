module Evergreen.V15.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V15.DuckDb
import Evergreen.V15.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V15.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V15.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V15.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V15.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V15.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V15.QueryBuilder.ColumnRef Evergreen.V15.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V15.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V15.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V15.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V15.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V15.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V15.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V15.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V15.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V15.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V15.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V15.QueryBuilder.ColumnRef Evergreen.V15.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V15.QueryBuilder.ColumnRef Evergreen.V15.QueryBuilder.Aggregation
