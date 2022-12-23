module Evergreen.V56.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V56.DuckDb
import Evergreen.V56.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V56.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V56.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V56.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V56.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V56.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V56.QueryBuilder.ColumnRef Evergreen.V56.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V56.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V56.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V56.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V56.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V56.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V56.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V56.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V56.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V56.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V56.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V56.QueryBuilder.ColumnRef Evergreen.V56.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V56.QueryBuilder.ColumnRef Evergreen.V56.QueryBuilder.Aggregation
