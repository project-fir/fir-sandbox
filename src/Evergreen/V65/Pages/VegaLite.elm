module Evergreen.V65.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V65.FirApi
import Evergreen.V65.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V65.FirApi.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V65.FirApi.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V65.FirApi.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V65.FirApi.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V65.FirApi.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V65.QueryBuilder.ColumnRef Evergreen.V65.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V65.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V65.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V65.FirApi.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V65.FirApi.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V65.FirApi.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V65.FirApi.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V65.FirApi.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V65.FirApi.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V65.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V65.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V65.QueryBuilder.ColumnRef Evergreen.V65.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V65.QueryBuilder.ColumnRef Evergreen.V65.QueryBuilder.Aggregation
