module Evergreen.V43.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V43.DuckDb
import Evergreen.V43.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V43.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V43.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V43.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V43.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V43.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V43.QueryBuilder.ColumnRef Evergreen.V43.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V43.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V43.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V43.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V43.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V43.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V43.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V43.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V43.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V43.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V43.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V43.QueryBuilder.ColumnRef Evergreen.V43.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V43.QueryBuilder.ColumnRef Evergreen.V43.QueryBuilder.Aggregation
