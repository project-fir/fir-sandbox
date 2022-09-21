module Evergreen.V17.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V17.DuckDb
import Evergreen.V17.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V17.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V17.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V17.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V17.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V17.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V17.QueryBuilder.ColumnRef Evergreen.V17.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V17.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V17.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V17.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V17.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V17.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V17.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V17.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V17.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V17.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V17.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V17.QueryBuilder.ColumnRef Evergreen.V17.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V17.QueryBuilder.ColumnRef Evergreen.V17.QueryBuilder.Aggregation
