module Evergreen.V1.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V1.Api
import Evergreen.V1.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V1.Api.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V1.Api.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V1.Api.DuckDbTableRefsResponse
    , selectedTableRef : Maybe Evergreen.V1.Api.TableRef
    , hoveredOnTableRef : Maybe Evergreen.V1.Api.TableRef
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V1.QueryBuilder.ColumnRef Evergreen.V1.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V1.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V1.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V1.Api.TableRef
    | GotDuckDbResponse (Result Http.Error Evergreen.V1.Api.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V1.Api.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V1.Api.DuckDbTableRefsResponse)
    | UserSelectedTableRef Evergreen.V1.Api.TableRef
    | UserMouseEnteredTableRef Evergreen.V1.Api.TableRef
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V1.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V1.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V1.QueryBuilder.ColumnRef Evergreen.V1.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V1.QueryBuilder.ColumnRef Evergreen.V1.QueryBuilder.Aggregation
