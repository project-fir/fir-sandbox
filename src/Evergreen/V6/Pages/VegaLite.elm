module Evergreen.V6.Pages.VegaLite exposing (..)

import Dict
import Evergreen.V6.DuckDb
import Evergreen.V6.QueryBuilder
import Http
import RemoteData


type Position
    = Up
    | Middle
    | Down


type alias Model =
    { duckDbForPlotResponse : RemoteData.WebData Evergreen.V6.DuckDb.DuckDbQueryResponse
    , duckDbMetaResponse : RemoteData.WebData Evergreen.V6.DuckDb.DuckDbMetaResponse
    , duckDbTableRefs : RemoteData.WebData Evergreen.V6.DuckDb.DuckDbTableRefsResponse
    , selectedTableRef : Maybe Evergreen.V6.DuckDb.TableName
    , hoveredOnTableRef : Maybe Evergreen.V6.DuckDb.TableName
    , data :
        { count : Int
        , position : Position
        }
    , selectedColumns : Dict.Dict Evergreen.V6.QueryBuilder.ColumnRef Evergreen.V6.QueryBuilder.KimballColumn
    , kimballCols : List Evergreen.V6.QueryBuilder.KimballColumn
    , openedDropDown : Maybe Evergreen.V6.QueryBuilder.ColumnRef
    }


type Msg
    = FetchPlotData
    | FetchTableRefs
    | FetchMetaDataForRef Evergreen.V6.DuckDb.TableName
    | GotDuckDbResponse (Result Http.Error Evergreen.V6.DuckDb.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error Evergreen.V6.DuckDb.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error Evergreen.V6.DuckDb.DuckDbTableRefsResponse)
    | UserSelectedTableRef Evergreen.V6.DuckDb.TableName
    | UserMouseEnteredTableRef Evergreen.V6.DuckDb.TableName
    | UserMouseLeftTableRef
    | UserClickKimballColumnTab Evergreen.V6.QueryBuilder.KimballColumn
    | DropDownToggled Evergreen.V6.QueryBuilder.ColumnRef
    | DropDownSelected_Time Evergreen.V6.QueryBuilder.ColumnRef Evergreen.V6.QueryBuilder.TimeClass
    | DropDownSelected_Agg Evergreen.V6.QueryBuilder.ColumnRef Evergreen.V6.QueryBuilder.Aggregation
