module Evergreen.V21.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V21.DuckDb
import Evergreen.V21.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V21.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V21.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V21.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V21.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V21.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V21.QueryBuilder.ColumnRef Evergreen.V21.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V21.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V21.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V21.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V21.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V21.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V21.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V21.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V21.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V21.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V21.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V21.QueryBuilder.ColumnRef Evergreen.V21.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V21.QueryBuilder.ColumnRef Evergreen.V21.QueryBuilder.Aggregation
