module Pages.Kimball exposing (Model, Msg, page)

import Browser.Events as BE
import Dict exposing (Dict)
import DuckDb exposing (ColumnName, DuckDbColumn, DuckDbColumnDescription(..), DuckDbRef, DuckDbRef_(..), fetchDuckDbTableRefs, refEquals, refToString)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Kimball exposing (Params)
import Html.Events.Extra.Mouse as Mouse exposing (Event)
import Http
import Json.Decode as JD
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


type alias RefString =
    String


type alias TableRenderInfo =
    { pos : PositionPx
    , ref : DuckDb.DuckDbRef
    }


type alias SvgViewBoxDimensions =
    { width : Float
    , height : Float
    , viewBoxXMin : Float
    , viewBoxYMin : Float
    , viewBoxWidth : Float
    , viewBoxHeight : Float
    }


type alias Model =
    { duckDbRefs : WebData DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe DuckDb.DuckDbRef
    , hoveredOnNodeTitle : Maybe DuckDb.DuckDbRef
    , tables : List Table
    , tableRenderInfo : Dict RefString TableRenderInfo
    , svgViewBox : SvgViewBoxDimensions
    , dragState : DragState
    , mouseEvent : Maybe Event
    }


type DragState
    = Idle
    | DragInitiated DuckDb.DuckDbRef
    | Dragging DuckDb.DuckDbRef (Maybe Event) Event TableRenderInfo


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



-- begin region: ref utils


refDrillDown : DuckDbRef_ -> DuckDbRef
refDrillDown ref =
    case ref of
        DuckDb.View vRef ->
            vRef

        DuckDb.Table tRef ->
            tRef


refOfTable : Table -> DuckDbRef
refOfTable table =
    case table of
        Fact ref _ ->
            refDrillDown ref

        Dim ref _ ->
            refDrillDown ref


refStringOfTable : Table -> RefString
refStringOfTable table =
    case table of
        Fact ref _ ->
            refToString (refDrillDown ref)

        Dim ref _ ->
            refToString (refDrillDown ref)



-- end region: ref utils


defaultViewBox : SvgViewBoxDimensions
defaultViewBox =
    { width = 1200
    , height = 800
    , viewBoxXMin = 0
    , viewBoxYMin = 0
    , viewBoxWidth = 1200
    , viewBoxHeight = 800
    }


init : ( Model, Effect Msg )
init =
    ( { duckDbRefs = Loading -- Must also fetch table refs below
      , selectedTableRef = Nothing
      , hoveredOnTableRef = Nothing
      , tables = [ demoFact, demoDim1 ]
      , tableRenderInfo =
            Dict.fromList
                [ ( refStringOfTable demoFact
                  , { pos = { x = 0, y = 400 }
                    , ref = refOfTable demoFact
                    }
                  )
                , ( refStringOfTable demoDim1
                  , { pos = { x = 950, y = 250 }
                    , ref = refOfTable demoDim1
                    }
                  )
                ]
      , hoveredOnNodeTitle = Nothing
      , svgViewBox = defaultViewBox
      , dragState = Idle
      , mouseEvent = Nothing
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
    | UserMouseEnteredNodeTitleBar DuckDb.DuckDbRef
    | UserMouseLeftNodeTitleBar
    | ClearNodeHoverState
    | SvgViewBoxTransform SvgViewBoxTransformation
    | BeginNodeDrag DuckDb.DuckDbRef
    | DraggedAt Event
    | DragStoppedAt Event
    | TerminateDrags


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float
    | Reset


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        TerminateDrags ->
            ( { model | dragState = Idle }, Effect.none )

        DraggedAt mouseEvent ->
            let
                ( newDragState, updatedTableInfo ) =
                    case model.dragState of
                        Idle ->
                            ( Idle, Nothing )

                        DragInitiated ref ->
                            let
                                anchoredInfo : Maybe TableRenderInfo
                                anchoredInfo =
                                    Dict.get (refToString ref) model.tableRenderInfo
                            in
                            case anchoredInfo of
                                Nothing ->
                                    ( Idle, Nothing )

                                Just anchoredInfo_ ->
                                    ( Dragging ref Nothing mouseEvent anchoredInfo_, Nothing )

                        Dragging ref firstEvent oldEvent anchoredInfo ->
                            case firstEvent of
                                Nothing ->
                                    ( Dragging ref (Just oldEvent) mouseEvent anchoredInfo, Nothing )

                                Just firstEvent_ ->
                                    let
                                        dx : Float
                                        dx =
                                            Tuple.first mouseEvent.clientPos - Tuple.first firstEvent_.clientPos

                                        dy : Float
                                        dy =
                                            Tuple.second mouseEvent.clientPos - Tuple.second firstEvent_.clientPos

                                        updatedInfo : TableRenderInfo
                                        updatedInfo =
                                            { pos =
                                                { x = anchoredInfo.pos.x + dx
                                                , y = anchoredInfo.pos.y + dy
                                                }
                                            , ref = anchoredInfo.ref
                                            }
                                    in
                                    ( Dragging ref (Just firstEvent_) mouseEvent anchoredInfo, Just updatedInfo )

                newTableInfos : Dict RefString TableRenderInfo
                newTableInfos =
                    case updatedTableInfo of
                        Nothing ->
                            model.tableRenderInfo

                        Just info ->
                            Dict.insert (refToString info.ref) info model.tableRenderInfo
            in
            ( { model
                | mouseEvent = Just mouseEvent
                , dragState = newDragState
                , tableRenderInfo = newTableInfos
              }
            , Effect.none
            )

        BeginNodeDrag ref ->
            ( { model | dragState = DragInitiated ref }, Effect.none )

        DragStoppedAt _ ->
            ( { model | dragState = Idle }, Effect.none )

        SvgViewBoxTransform transformation ->
            case transformation of
                Zoom dz ->
                    let
                        dx =
                            model.svgViewBox.width * (0.5 * dz)

                        dy =
                            model.svgViewBox.height * (0.5 * dz)

                        newViewBox =
                            { width = model.svgViewBox.width
                            , height = model.svgViewBox.height
                            , viewBoxXMin = model.svgViewBox.viewBoxXMin + dx
                            , viewBoxYMin = model.svgViewBox.viewBoxYMin + dy
                            , viewBoxWidth = model.svgViewBox.viewBoxWidth * (1.0 - dz)
                            , viewBoxHeight = model.svgViewBox.viewBoxHeight * (1.0 - dz)
                            }
                    in
                    ( { model | svgViewBox = newViewBox }, Effect.none )

                Translation dx dy ->
                    let
                        newViewBox =
                            { width = model.svgViewBox.width
                            , height = model.svgViewBox.height
                            , viewBoxXMin = model.svgViewBox.viewBoxXMin + dx
                            , viewBoxYMin = model.svgViewBox.viewBoxYMin + dy
                            , viewBoxWidth = model.svgViewBox.viewBoxWidth
                            , viewBoxHeight = model.svgViewBox.viewBoxHeight
                            }
                    in
                    ( { model | svgViewBox = newViewBox }, Effect.none )

                Reset ->
                    ( { model | svgViewBox = defaultViewBox }, Effect.none )

        ClearNodeHoverState ->
            ( { model | hoveredOnNodeTitle = Nothing }, Effect.none )

        UserMouseEnteredNodeTitleBar ref ->
            ( { model | hoveredOnNodeTitle = Just ref }, Effect.none )

        UserMouseLeftNodeTitleBar ->
            ( { model
                | hoveredOnNodeTitle = Nothing
              }
            , Effect.none
            )

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
    case model.dragState of
        Idle ->
            Sub.none

        DragInitiated _ ->
            Sub.batch
                [ BE.onMouseMove (JD.map DraggedAt Mouse.eventDecoder)
                , BE.onMouseUp (JD.map DragStoppedAt Mouse.eventDecoder)
                ]

        Dragging _ _ _ _ ->
            Sub.batch
                [ BE.onMouseMove (JD.map DraggedAt Mouse.eventDecoder)
                , BE.onMouseUp (JD.map DragStoppedAt Mouse.eventDecoder)
                ]



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
    { x : Float
    , y : Float
    }


viewDataSourceNode : Model -> Table -> PositionPx -> Svg Msg
viewDataSourceNode model table pos =
    let
        ( table_, type_, backgroundColor ) =
            case table of
                Fact _ t ->
                    ( t, "Fact", Palette.lightBlue )

                Dim _ t ->
                    ( t, "Dimension", Palette.green_keylime )

        ref : DuckDbRef
        ref =
            refOfTable table

        cols : List DuckDbColumnDescription
        cols =
            case table of
                Fact _ cols_ ->
                    cols_

                Dim _ cols_ ->
                    cols_

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
            row
                [ width E.fill
                , moveRight 3
                , paddingXY 5 2
                , spacingXY 4 0

                --, Events.onClick <| UserSelectedTableRef ref
                --, Events.onMouseEnter <| UserMouseEnteredTableRef ref
                --, Events.onMouseLeave <| UserMouseLeftTableRef
                --, Background.color (backgroundColorFor ref)
                --, Border.widthEach (borderFor ref)
                --, Border.color (borderColorFor ref)
                ]
                [ el
                    [ width <| px 5
                    , height <| px 5
                    , Border.width 1
                    , Background.color Palette.lightGrey
                    ]
                    E.none
                , text name
                , el
                    [ width <| px 5
                    , height <| px 5
                    , Border.width 1
                    , Background.color Palette.lightGrey
                    , alignRight
                    ]
                    E.none
                ]

        element : Element Msg
        element =
            let
                titleBarBackgroundColor =
                    case model.hoveredOnNodeTitle of
                        Nothing ->
                            backgroundColor

                        Just ref_ ->
                            if refEquals ref ref_ then
                                Palette.darkishGrey

                            else
                                backgroundColor
            in
            column
                [ width fill
                , height fill
                , Border.color Palette.black
                , Border.width 2
                , padding 2
                , Background.color backgroundColor
                , Font.size 14
                ]
                ([ el
                    [ Border.widthEach { top = 0, left = 0, right = 0, bottom = 2 }
                    , Border.color Palette.black
                    , width fill
                    , Background.color titleBarBackgroundColor
                    , Events.onMouseEnter (UserMouseEnteredNodeTitleBar (refOfTable table))
                    , Events.onMouseLeave UserMouseLeftNodeTitleBar
                    , Events.onMouseDown (BeginNodeDrag (refOfTable table))
                    , paddingXY 0 5
                    ]
                   <|
                    row [ width fill, paddingXY 5 0 ]
                        [ el [ alignLeft ] (E.text <| type_ ++ ":")
                        , el [ alignLeft, moveRight 10 ] (E.text title)
                        ]
                 ]
                    ++ List.map (\col -> viewColumn col) cols
                )
    in
    SC.foreignObject
        [ SA.x (ST.px pos.x)
        , SA.y (ST.px pos.y)
        , SA.width (ST.px 250)
        , SA.height (ST.px 350)
        ]
        [ E.layoutWith { options = [ noStaticStyleSheet ] } [ Events.onMouseLeave ClearNodeHoverState ] element ]


viewCanvas : Model -> Element Msg
viewCanvas model =
    let
        renderHelp : Table -> Svg Msg
        renderHelp tbl =
            let
                key : RefString
                key =
                    refStringOfTable tbl

                info : TableRenderInfo
                info =
                    case Dict.get key model.tableRenderInfo of
                        Just info_ ->
                            info_

                        Nothing ->
                            { pos = { x = 0, y = 0 }
                            , ref = refOfTable tbl
                            }
            in
            viewDataSourceNode model tbl info.pos
    in
    el
        [ Border.width 1
        , Border.color Palette.darkishGrey
        , Events.onMouseLeave TerminateDrags
        , centerY
        , centerX
        , Background.color Palette.white
        ]
    <|
        E.html <|
            S.svg
                [ SA.width (ST.px model.svgViewBox.width)
                , SA.height (ST.px model.svgViewBox.height)
                , SA.viewBox model.svgViewBox.viewBoxXMin model.svgViewBox.viewBoxYMin model.svgViewBox.viewBoxWidth model.svgViewBox.viewBoxHeight
                ]
                (List.map (\tbl -> renderHelp tbl) model.tables)


viewViewBoxControls : Model -> Element Msg
viewViewBoxControls model =
    row
        [ width fill
        , height (px 100)
        , Font.size 30
        , spacing 4
        ]
        [ el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Zoom 0.1) ] <| E.text "+"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Zoom -0.1) ] <| E.text "-"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform Reset ] <| E.text "reset"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation -20 0) ] <| E.text "ᐊ"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation 20 0) ] <| E.text "ᐅ"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation 0 -20) ] <| E.text "ᐃ"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation 0 20) ] <| E.text "ᐁ"
        ]


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
            , viewViewBoxControls model
            ]
        , column
            [ height fill
            , width <| fillPortion 2
            , Border.width 1
            , Border.color Palette.darkishGrey
            , padding 5
            ]
            [ viewTableRefs model
            , viewDebugPanel model
            ]
        ]


viewDebugPanel : Model -> Element Msg
viewDebugPanel model =
    let
        dragStateStr : String
        dragStateStr =
            case model.dragState of
                Idle ->
                    "idle"

                DragInitiated ref ->
                    "drag initiated on " ++ refToString ref

                Dragging ref first current anchorInfo ->
                    let
                        firstStr =
                            case first of
                                Nothing ->
                                    "(,)"

                                Just first_ ->
                                    "(" ++ String.fromFloat (Tuple.first first_.clientPos) ++ ", " ++ String.fromFloat (Tuple.second first_.clientPos) ++ ")"

                        currentStr =
                            "(" ++ String.fromFloat (Tuple.first current.clientPos) ++ ", " ++ String.fromFloat (Tuple.second current.clientPos) ++ ")"
                    in
                    "dragging " ++ refToString ref ++ " " ++ firstStr ++ " " ++ currentStr

        mouseEventStr : String
        mouseEventStr =
            case model.mouseEvent of
                Nothing ->
                    "No events"

                Just event ->
                    "(" ++ String.fromFloat (Tuple.first event.clientPos) ++ ", " ++ String.fromFloat (Tuple.second event.clientPos) ++ ")"
    in
    column [ width fill, height fill ]
        [ E.text <| "events: " ++ mouseEventStr
        , E.text <| "drag state: " ++ dragStateStr
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
