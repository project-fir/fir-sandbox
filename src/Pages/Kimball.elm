module Pages.Kimball exposing (Model, Msg(..), page)

import Bridge exposing (BackendData(..), ToBackend(..))
import Browser.Dom
import Browser.Events as BE
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModelRef, PositionPx, TableRenderInfo)
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
import Lamdera exposing (sendToBackend)
import Page
import Palette
import QueryBuilder exposing (Aggregation(..), ColumnRef, Granularity(..), TimeClass(..))
import RemoteData exposing (RemoteData(..), WebData)
import Request
import Shared
import Task
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


type alias Model =
    { duckDbRefs : WebData DuckDb.DuckDbRefsResponse
    , selectedTableRef : Maybe DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe DuckDb.DuckDbRef
    , tables : List Table
    , tableRenderInfo : Dict RefString TableRenderInfo
    , dragState : DragState
    , mouseEvent : Maybe Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : BackendData (List DimensionalModelRef)
    , proposedNewModelName : String
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


type PageRenderStatus
    = AwaitingDomInfo
    | Ready LayoutInfo



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
      , dragState = Idle
      , mouseEvent = Nothing
      , pageRenderStatus = AwaitingDomInfo
      , dimensionalModelRefs = Fetching_
      , viewPort = Nothing
      , proposedNewModelName = ""
      }
    , Effect.fromCmd <|
        Cmd.batch
            [ fetchDuckDbTableRefs GotDuckDbTableRefsResponse
            , Task.perform GotViewport Browser.Dom.getViewport
            ]
    )


type DimType
    = Causal
    | NonCausal


type Table
    = Fact DuckDbRef_ (List DuckDbColumnDescription)
    | Dim DuckDbRef_ (List DuckDbColumnDescription)


type alias LayoutInfo =
    { mainPanelWidth : Int
    , mainPanelHeight : Int
    , sidePanelWidth : Int
    , canvasElementWidth : Float
    , canvasElementHeight : Float
    , viewBoxXMin : Float
    , viewBoxYMin : Float
    , viewBoxWidth : Float
    , viewBoxHeight : Float
    }


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List DimensionalModelRef)
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
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | UpdatedNewDimModelName String
    | UserCreatesNewDimensionalModel DimensionalModelRef


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotDimensionalModelRefs refs ->
            ( { model | dimensionalModelRefs = Success_ refs }, Effect.none )

        GotViewport viewPort ->
            let
                mainPanelWidth : Int
                mainPanelWidth =
                    round <| (viewPort.viewport.width * 0.8)

                mainPanelHeight : Int
                mainPanelHeight =
                    200

                sidePanelWidth : Int
                sidePanelWidth =
                    min 300 (round viewPort.viewport.width - mainPanelWidth - 5)

                canvasPanelWidth : Float
                canvasPanelWidth =
                    toFloat mainPanelWidth - 5

                canvasPanelHeight : Float
                canvasPanelHeight =
                    viewPort.viewport.height - 85

                layout : LayoutInfo
                layout =
                    { mainPanelWidth = mainPanelWidth
                    , mainPanelHeight = mainPanelHeight
                    , sidePanelWidth = sidePanelWidth
                    , canvasElementWidth = canvasPanelWidth
                    , canvasElementHeight = canvasPanelHeight
                    , viewBoxXMin = 0
                    , viewBoxYMin = 0
                    , viewBoxWidth = canvasPanelWidth
                    , viewBoxHeight = canvasPanelHeight
                    }
            in
            ( { model
                | viewPort = Just viewPort
                , pageRenderStatus = Ready layout
              }
            , Effect.fromCmd <| sendToBackend FetchDimensionalModelRefs
            )

        GotResizeEvent _ _ ->
            -- rather than keeping two copies of this info in memory, chain a resize event
            -- to the existing flow on first page render. This should avoid strange resizing
            -- frames from being rendered.. at least I hope so!
            ( { model | pageRenderStatus = AwaitingDomInfo }, Effect.fromCmd (Task.perform GotViewport Browser.Dom.getViewport) )

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
                            model.tableRenderInfo

                --Dict.insert (refToString info.ref) info model.tableRenderInfo
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
            let
                info : Maybe LayoutInfo
                info =
                    case model.pageRenderStatus of
                        Ready info_ ->
                            Just info_

                        AwaitingDomInfo ->
                            Nothing
            in
            case info of
                Nothing ->
                    ( model, Effect.none )

                Just layoutInfo ->
                    case transformation of
                        Zoom dz ->
                            let
                                dx : Float
                                dx =
                                    layoutInfo.viewBoxWidth * (0.5 * dz)

                                dy : Float
                                dy =
                                    layoutInfo.viewBoxHeight * (0.5 * dz)

                                newLayoutInfo : LayoutInfo
                                newLayoutInfo =
                                    { layoutInfo
                                        | viewBoxWidth = layoutInfo.viewBoxWidth - dx
                                        , viewBoxHeight = layoutInfo.viewBoxHeight - dy
                                        , viewBoxXMin = layoutInfo.viewBoxXMin + (0.5 * dx)
                                        , viewBoxYMin = layoutInfo.viewBoxXMin + (0.5 * dy)
                                    }
                            in
                            ( { model | pageRenderStatus = Ready newLayoutInfo }, Effect.none )

                        Translation dx dy ->
                            let
                                newLayoutInfo : LayoutInfo
                                newLayoutInfo =
                                    { layoutInfo
                                        | viewBoxXMin = layoutInfo.viewBoxXMin + dx
                                        , viewBoxYMin = layoutInfo.viewBoxYMin + dy
                                    }
                            in
                            ( { model | pageRenderStatus = Ready newLayoutInfo }, Effect.none )

        --( { model | svgViewBox = defaultViewBox }, Effect.none )
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

        UpdatedNewDimModelName newStr ->
            ( { model | proposedNewModelName = newStr }, Effect.none )

        UserCreatesNewDimensionalModel ref ->
            ( model, Effect.fromCmd <| sendToBackend (CreateNewDimensionalModel ref) )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        dragSubs : List (Sub Msg)
        dragSubs =
            case model.dragState of
                Idle ->
                    []

                DragInitiated _ ->
                    [ BE.onMouseMove (JD.map DraggedAt Mouse.eventDecoder)
                    , BE.onMouseUp (JD.map DragStoppedAt Mouse.eventDecoder)
                    ]

                Dragging _ _ _ _ ->
                    [ BE.onMouseMove (JD.map DraggedAt Mouse.eventDecoder)
                    , BE.onMouseUp (JD.map DragStoppedAt Mouse.eventDecoder)
                    ]
    in
    -- Always listen to Browser events, but only listen to drag events if we believe we're dragging!
    Sub.batch
        ([ BE.onResize GotResizeEvent ]
            ++ dragSubs
        )



-- begin region view


view : Model -> View Msg
view model =
    let
        title =
            "Kimball Assignments"
    in
    { title = title
    , body =
        [ case model.pageRenderStatus of
            AwaitingDomInfo ->
                E.none

            Ready layoutInfo ->
                viewElements model layoutInfo
        ]
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


viewCanvas : Model -> LayoutInfo -> Element Msg
viewCanvas model layoutInfo =
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
                [ SA.width (ST.px layoutInfo.canvasElementWidth)
                , SA.height (ST.px layoutInfo.canvasElementHeight)
                , SA.viewBox layoutInfo.viewBoxXMin layoutInfo.viewBoxYMin layoutInfo.viewBoxWidth layoutInfo.viewBoxHeight
                ]
                (List.map (\tbl -> renderHelp tbl) model.tables)


viewViewBoxControls : Element Msg
viewViewBoxControls =
    row
        [ width fill
        , height (px 40)
        , Font.size 30
        , Border.width 1
        , Background.color Palette.white
        , Border.color Palette.darkishGrey
        , spacing 6
        ]
        [ el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Zoom 0.1) ] <| E.text "+"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Zoom -0.1) ] <| E.text "-"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation -20 0) ] <| E.text "ᐊ"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation 20 0) ] <| E.text "ᐅ"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation 0 -20) ] <| E.text "ᐃ"
        , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation 0 20) ] <| E.text "ᐁ"
        ]


viewElements : Model -> LayoutInfo -> Element Msg
viewElements model layoutInfo =
    row
        [ width fill
        , height fill
        , centerX
        , centerY
        , Background.color Palette.lightGrey
        ]
        [ column
            [ height fill
            , width (px layoutInfo.mainPanelWidth)
            , paddingXY 0 3
            , Background.color Palette.lightGrey
            , centerX
            ]
            [ viewCanvas model layoutInfo
            , viewViewBoxControls
            ]
        , column
            [ height fill
            , width (px layoutInfo.sidePanelWidth)
            , Background.color Palette.white
            , Border.width 1
            , Border.color Palette.darkishGrey
            , clipX
            , scrollbarX
            , alignRight
            ]
            [ viewDimensionalModelRefs model
            , viewTableRefs model
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

        viewPortStr : String
        viewPortStr =
            case model.viewPort of
                Nothing ->
                    "No viewport known"

                Just viewPort ->
                    "(" ++ String.fromFloat viewPort.viewport.x ++ ", " ++ String.fromFloat viewPort.viewport.y ++ ", " ++ String.fromFloat viewPort.viewport.width ++ ", " ++ String.fromFloat viewPort.viewport.height ++ ")"
    in
    column [ width fill, height fill, Border.width 1, Border.color Palette.darkishGrey ]
        [ E.text <| "events: " ++ mouseEventStr
        , E.text <| "drag state: " ++ dragStateStr
        , E.text <| "veiwPort: " ++ viewPortStr
        ]


viewDimensionalModelRefs : Model -> Element Msg
viewDimensionalModelRefs model =
    let
        refsElement : Element Msg
        refsElement =
            case model.dimensionalModelRefs of
                NotAsked_ ->
                    E.text "Awaiting input to fetch refs"

                Fetching_ ->
                    E.text "Fetching..."

                Success_ refs ->
                    column [ width fill ]
                        (List.map (\r -> E.text r) refs)

                Error_ ->
                    E.text "Error!"

        newModelForm : Element Msg
        newModelForm =
            row [ width fill ]
                [ Input.text []
                    { onChange = UpdatedNewDimModelName
                    , text = model.proposedNewModelName
                    , placeholder = Just <| Input.placeholder [] (E.text "4+ letters")
                    , label = Input.labelLeft [] (E.text "Name:")
                    }
                , Input.button [ alignRight ]
                    { label =
                        el
                            [ Border.width 1
                            , Border.rounded 2
                            , Border.color Palette.black
                            , Font.size 20
                            ]
                            (E.text " + ")
                    , onPress = Just <| UserCreatesNewDimensionalModel model.proposedNewModelName
                    }
                ]
    in
    column [ width fill ]
        [ E.text "Dimensional models:"
        , refsElement
        , newModelForm
        ]


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
                , height (px 300)
                , spacing 2
                , alignTop
                , Border.width 1
                , Border.color Palette.darkishGrey
                , clipX
                , scrollbarX
                , clipY
                , scrollbarY
                ]
                [ text "DuckDB Refs:"
                , refsSelector refsResponse.refs
                ]

        Failure err ->
            case err of
                Http.BadUrl string ->
                    text <| "Bad URL: " ++ string

                Http.Timeout ->
                    text <| "Network timeout!"

                Http.NetworkError ->
                    text <| "Network error!"

                Http.BadStatus int ->
                    text <| "Bad statu: " ++ String.fromInt int

                Http.BadBody string ->
                    text <| "Error - bad body: " ++ string



-- end region view
