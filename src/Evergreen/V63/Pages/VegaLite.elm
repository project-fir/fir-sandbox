module Evergreen.V63.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V63.FirApi
import Evergreen.V63.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V63.FirApi.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V63.FirApi.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V63.FirApi.DuckDbRefsResponse
    , selectedTableRef : Maybe Evergreen.V63.FirApi.DuckDbRef
    , hoveredOnTableRef : Maybe Evergreen.V63.FirApi.DuckDbRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V63.QueryBuilder.ColumnRef Evergreen.V63.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V63.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V63.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V63.FirApi.DuckDbRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V63.FirApi.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V63.FirApi.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V63.FirApi.DuckDbRefsResponse)
    | UserSelectedTableRef Evergreen.V63.FirApi.DuckDbRef
    | UserMouseEnteredTableRef Evergreen.V63.FirApi.DuckDbRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V63.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V63.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V63.QueryBuilder.ColumnRef Evergreen.V63.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V63.QueryBuilder.ColumnRef Evergreen.V63.QueryBuilder.Aggregation
