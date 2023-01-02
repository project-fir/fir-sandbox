module Evergreen.V64.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V64.FirApi
import Evergreen.V64.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V64.FirApi.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V64.FirApi.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V64.FirApi.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V64.FirApi.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V64.FirApi.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V64.QueryBuilder.ColumnRef Evergreen.V64.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V64.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V64.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V64.FirApi.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V64.FirApi.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V64.FirApi.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V64.FirApi.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V64.FirApi.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V64.FirApi.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V64.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V64.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V64.QueryBuilder.ColumnRef Evergreen.V64.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V64.QueryBuilder.ColumnRef Evergreen.V64.QueryBuilder.Aggregation
