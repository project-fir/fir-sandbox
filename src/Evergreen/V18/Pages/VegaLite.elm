module Evergreen.V18.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V18.DuckDb
import Evergreen.V18.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V18.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V18.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V18.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V18.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V18.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V18.QueryBuilder.ColumnRef Evergreen.V18.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V18.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V18.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V18.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V18.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V18.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V18.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V18.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V18.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V18.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V18.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V18.QueryBuilder.ColumnRef Evergreen.V18.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V18.QueryBuilder.ColumnRef Evergreen.V18.QueryBuilder.Aggregation
