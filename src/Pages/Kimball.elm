module Pages.Kimball exposing (Model, Msg, page)

import DuckDb exposing (ColumnName, DuckDbColumn, DuckDbColumnDescription(..), DuckDbRef_(..), fetchDuckDbTableRefs, refToString)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Kimball exposing (Params)
import Http
import Page
import Palette
import QueryBuilder exposing (Aggregation(..), ColumnRef, Granularity(..), TimeClass(..))
import RemoteData exposing (RemoteData(..), WebData)
import Request
import Shared
import TypedSvg as S
import TypedSvg.Attributes as SA
import TypedSvg.Core as SC exposing (Svg)
import TypedSvg.Types as ST
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type
    KimballColumn
    -- DEPRECATED: To preserve functionality pre-/kimball assignment page I'm keeping this around, but should not be
    --             used
    -- TODO: Move old functionality to new
    = Dimension ColumnRef
    | Measure Aggregation ColumnRef
    | Time TimeClass ColumnRef
    | Error ColumnRef



-- INIT


type alias Model =
    { duckDbRefs : WebData DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe DuckDb.DuckDbRef
    , tables : List Table
    , pos : PositionPx
    , message : String
    }


demoFact : Table
demoFact =
    Fact (DuckDb.Table { schemaName = "dwtk_demo", tableName = "fact1" })
        [ Persisted_
            { name = "col_1"
            , parentRef = Table { schemaName = "dwtk_demo", tableName = "fact1" }
            , dataType = "VARCHAR"
            }
        , Persisted_
            { name = "col_2"
            , parentRef = Table { schemaName = "dwtk_demo", tableName = "fact1" }
            , dataType = "VARCHAR"
            }
        , Computed_
            { name = "col_3__agg"

            --, parentRef = Table { schemaName = "dwtk_demo", tableName = "fact1" }
            , dataType = "FLOAT"
            }
        ]


demoDim1 : Table
demoDim1 =
    Dim (DuckDb.Table { schemaName = "dwtk_demo", tableName = "dim1" })
        [ Persisted_
            { name = "col_a"
            , parentRef = Table { schemaName = "dwtk_demo", tableName = "dim1" }
            , dataType = "VARCHAR"
            }
        , Persisted_
            { name = "col_b"
            , parentRef = Table { schemaName = "dwtk_demo", tableName = "dim1" }
            , dataType = "VARCHAR"
            }
        ]


init : ( Model, Effect Msg )
init =
    ( { duckDbRefs = Loading -- Must also fetch table refs below
      , selectedTableRef = Nothing
      , hoveredOnTableRef = Nothing
      , tables = [ demoFact, demoDim1 ]
      , pos = { ex = 400, y = 250 }
      , message = "init message"
      }
    , Effect.fromCmd <| fetchDuckDbTableRefs GotDuckDbTableRefsResponse
    )


type DimType
    = Causal
    | NonCausal


type Table
    = Fact DuckDbRef_ (List DuckDbColumnDescription)
    | Dim DuckDbRef_ (List DuckDbColumnDescription)


type
    Msg
    --| FetchMetaDataForRef DuckDb.DuckDbRef
    = FetchTableRefs
    | GotDuckDbTableRefsResponse (Result Http.Error DuckDb.DuckDbRefsResponse)
    | UserSelectedTableRef DuckDb.DuckDbRef
    | UserMouseEnteredTableRef DuckDb.DuckDbRef
    | UserMouseLeftTableRef


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        FetchTableRefs ->
            ( { model | duckDbRefs = Loading }, Effect.fromCmd <| fetchDuckDbTableRefs GotDuckDbTableRefsResponse )

        GotDuckDbTableRefsResponse response ->
            case response of
                Ok refs ->
                    ( { model | duckDbRefs = Success refs }, Effect.none )

                Err err ->
                    ( { model | duckDbRefs = Failure err }, Effect.none )

        UserSelectedTableRef ref ->
            ( model, Effect.none )

        UserMouseEnteredTableRef ref ->
            ( { model | hoveredOnTableRef = Just ref }, Effect.none )

        UserMouseLeftTableRef ->
            ( { model | hoveredOnTableRef = Nothing }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- begin region view


view : Model -> View Msg
view model =
    let
        title =
            "Kimball Assignments"
    in
    { title = title
    , body =
        [ elements model
        ]
    }


type alias PositionPx =
    { ex : Float
    , y : Float
    }


viewDataSourceNode : Table -> PositionPx -> Svg Msg
viewDataSourceNode table pos =
    let
        ( table_, type_, backgroundColor ) =
            case table of
                Fact ref t ->
                    ( t, "Fact", Palette.lightBlue )

                Dim ref t ->
                    ( t, "Dimension", Palette.green_keylime )

        isProperTable : List DuckDbColumnDescription -> Bool
        isProperTable t =
            True

        cols : List DuckDbColumnDescription
        cols =
            case table of
                Fact ref cols_ ->
                    cols_

                Dim ref cols_ ->
                    cols_

        --backgroundColor : Color.Color
        --backgroundColor =
        --    case isProperTable table_ of
        --        True ->
        --            Palette.toAvhColor Palette.lightBlue
        --
        --        False ->
        --            Palette.toAvhColor Palette.red
        title : String
        title =
            case List.head table_ of
                Nothing ->
                    "No Tables!"

                Just col ->
                    case col of
                        Persisted_ col_ ->
                            case col_.parentRef of
                                Table tRef ->
                                    refToString tRef

                                DuckDb.View vRef ->
                                    refToString vRef

                        Computed_ col_ ->
                            col_.name

        viewColumn : DuckDbColumnDescription -> Element Msg
        viewColumn col =
            let
                name : String
                name =
                    case col of
                        Persisted_ desc ->
                            desc.name

                        Computed_ desc ->
                            desc.name
            in
            el [] <| E.text name

        element : Element Msg
        element =
            column
                [ width fill
                , height fill
                , Border.color Palette.black
                , Border.width 2
                , padding 2
                , Background.color backgroundColor
                ]
                ([ el [] <| E.text title ] ++ List.map (\col -> viewColumn col) cols)
    in
    S.rect
        [ SA.x (ST.px pos.ex)
        , SA.y (ST.px pos.y)
        , SA.width (ST.px 250)
        , SA.height (ST.px 350)
        ]
        []



--SC.foreignObject
--
--    [ E.layoutWith { options = [ noStaticStyleSheet ] } [] element ]


viewCanvas : Model -> Element Msg
viewCanvas model =
    let
        poss : List PositionPx
        poss =
            [ { ex = 100, y = 100 }
            , { ex = 400, y = 250 }
            ]

        tables : List Table
        tables =
            [ demoFact, demoDim1 ]

        --List.map (\tbl -> tbl) model.tables
        viewStuff : String -> Element Msg
        viewStuff s =
            E.text s
    in
    el
        [ Border.width 1
        , Border.color Palette.darkishGrey
        , centerY
        , centerX
        , Background.color Palette.white
        ]
    <|
        viewStuff model.message



--E.html <|
--    S.svg
--        [ SA.height (ST.px 800)
--        , SA.width (ST.px 1200)
--        ]
--        [ viewStuff demoDim1 model.pos ]
--[ viewDataSourceNode demoFact { x = 100, y = 200 }
--, viewDataSourceNode demoDim1 { x = 400, y = 300 }
--]


elements : Model -> Element Msg
elements model =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ height fill
            , width <| fillPortion 8
            , padding 5
            , Background.color Palette.lightGrey
            ]
            [ viewCanvas model
            ]
        , el
            [ height fill
            , width <| fillPortion 2
            , Border.width 1
            , Border.color Palette.darkishGrey
            , padding 5
            ]
            (viewTableRefs model)
        ]


mapToKimball : DuckDbColumnDescription -> KimballColumn
mapToKimball r =
    -- TODO: this function serves to be placeholder logic in lieu of persisting Kimball metadata
    --       upon successful loading of a DuckDB Ref, columns will be mapped in a "best guess" manner
    --       this longer term intent is for this to be a 'first pass', when persisted meta data does not exist
    --       (which should be the case when a user is first using data!). Any user interventions should be
    --       persisted server-side
    let
        mapDataType : { r | dataType : String, name : ColumnName } -> KimballColumn
        mapDataType colDesc =
            case colDesc.dataType of
                "VARCHAR" ->
                    Dimension colDesc.name

                "DATE" ->
                    Time (Discrete Day) colDesc.name

                "TIMESTAMP" ->
                    Time Continuous colDesc.name

                "BOOLEAN" ->
                    Dimension colDesc.name

                "INTEGER" ->
                    Measure Sum colDesc.name

                "HUGEINT" ->
                    Measure Sum colDesc.name

                "BIGINT" ->
                    Measure Sum colDesc.name

                "DOUBLE" ->
                    Measure Sum colDesc.name

                _ ->
                    Error colDesc.name
    in
    case r of
        Persisted_ colDesc ->
            mapDataType colDesc

        Computed_ colDesc ->
            mapDataType colDesc


viewTableRefs : Model -> Element Msg
viewTableRefs model =
    case model.duckDbRefs of
        NotAsked ->
            text "Didn't request data yet"

        Loading ->
            text "Fetching..."

        Success refsResponse ->
            let
                refsSelector : List DuckDb.DuckDbRef -> Element Msg
                refsSelector refs =
                    let
                        backgroundColorFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    Palette.white

                                Just ref_ ->
                                    if ref == ref_ then
                                        Palette.lightGrey

                                    else
                                        Palette.white

                        borderColorFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    Palette.white

                                Just ref_ ->
                                    if ref == ref_ then
                                        Palette.darkishGrey

                                    else
                                        Palette.white

                        borderFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    { top = 1, left = 0, right = 0, bottom = 1 }

                                Just ref_ ->
                                    if ref == ref_ then
                                        { top = 1, left = 0, right = 0, bottom = 1 }

                                    else
                                        { top = 1, left = 0, right = 0, bottom = 1 }

                        innerBlobColorFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    Palette.white

                                Just ref_ ->
                                    if ref == ref_ then
                                        Palette.black

                                    else
                                        Palette.white

                        ui : DuckDb.DuckDbRef -> Element Msg
                        ui ref =
                            row
                                [ width E.fill
                                , paddingXY 0 2
                                , spacingXY 2 0
                                , Events.onClick <| UserSelectedTableRef ref
                                , Events.onMouseEnter <| UserMouseEnteredTableRef ref
                                , Events.onMouseLeave <| UserMouseLeftTableRef
                                , Background.color (backgroundColorFor ref)
                                , Border.widthEach (borderFor ref)
                                , Border.color (borderColorFor ref)
                                ]
                                [ el
                                    [ width <| px 5
                                    , height <| px 5
                                    , Border.width 1
                                    , Background.color (innerBlobColorFor ref)
                                    ]
                                    E.none
                                , text <| refToString ref
                                ]
                    in
                    column
                        [ width E.fill
                        , height E.fill
                        , paddingXY 5 0
                        ]
                    <|
                        List.map (\ref -> ui ref) refs
            in
            column
                [ width E.fill
                , height E.fill
                , spacing 2
                ]
                [ text "DuckDB Refs:"
                , refsSelector refsResponse.refs
                ]

        Failure err ->
            text "Error"



-- end region view
