module Evergreen.V50.QueryBuilder exposing (..)


type alias ColumnRef =
    String


type Aggregation
    = Sum
    | Mean
    | Median
    | Min
    | Max
    | Count
    | CountDistinct


type Granularity
    = Year
    | Quarter
    | Month
    | Week
    | Day
    | Hour
    | Minute


type TimeClass
    = Continuous
    | Discrete Granularity


type KimballColumn
    = Dimension ColumnRef
    | Measure Aggregation ColumnRef
    | Time TimeClass ColumnRef
    | Error ColumnRef
