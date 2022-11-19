module Evergreen.V35.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V35.DuckDb
import Evergreen.V35.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V35.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V35.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V35.DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V35.DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V35.DuckDb.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V35.QueryBuilder.ColumnRef Evergreen.V35.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V35.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V35.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V35.DuckDb.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V35.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V35.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V35.DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V35.DuckDb.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V35.DuckDb.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V35.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V35.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V35.QueryBuilder.ColumnRef Evergreen.V35.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V35.QueryBuilder.ColumnRef Evergreen.V35.QueryBuilder.Aggregation
