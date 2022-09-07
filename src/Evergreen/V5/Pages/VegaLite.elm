module Evergreen.V5.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V5.Api
import Evergreen.V5.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V5.Api.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V5.Api.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V5.Api.DuckDbTableRefsResponse
    , selectedTableRef : Maybe Evergreen.V5.Api.TableRef
    , hoveredOnTableRef : Maybe Evergreen.V5.Api.TableRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V5.QueryBuilder.ColumnRef Evergreen.V5.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V5.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V5.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V5.Api.TableRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V5.Api.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V5.Api.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V5.Api.DuckDbTableRefsResponse)
    | UserSelectedTableRef Evergreen.V5.Api.TableRef
    | UserMouseEnteredTableRef Evergreen.V5.Api.TableRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V5.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V5.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V5.QueryBuilder.ColumnRef Evergreen.V5.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V5.QueryBuilder.ColumnRef Evergreen.V5.QueryBuilder.Aggregation
