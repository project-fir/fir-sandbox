module Evergreen.V11.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V11.DuckDb
import Evergreen.V11.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V11.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V11.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V11.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V11.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V11.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V11.QueryBuilder.ColumnRef Evergreen.V11.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V11.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V11.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V11.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V11.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V11.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V11.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V11.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V11.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V11.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V11.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V11.QueryBuilder.ColumnRef Evergreen.V11.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V11.QueryBuilder.ColumnRef Evergreen.V11.QueryBuilder.Aggregation
