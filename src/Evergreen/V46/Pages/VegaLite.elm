module Evergreen.V46.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V46.DuckDb
import Evergreen.V46.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V46.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V46.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V46.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V46.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V46.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V46.QueryBuilder.ColumnRef Evergreen.V46.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V46.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V46.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V46.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V46.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V46.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V46.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V46.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V46.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V46.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V46.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V46.QueryBuilder.ColumnRef Evergreen.V46.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V46.QueryBuilder.ColumnRef Evergreen.V46.QueryBuilder.Aggregation
