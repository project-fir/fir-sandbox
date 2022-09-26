module Pages.Kimball exposing (Model, Msg(..), page)

import Bridge exposing (BackendData(..), BackendErrorMessage(..), DuckDbMetaDataCacheEntry, ToBackend(..))
import Browser.Dom
import Browser.Events as BE
import Dict exposing (Dict)
import DimensionalModel exposing (DimensionalModel, DimensionalModelRef, KimballAssignment(..), PositionPx, TableRenderInfo)
import DuckDb exposing (ColumnName, DuckDbColumn, DuckDbColumnDescription(..), DuckDbRef, DuckDbRefString, DuckDbRef_(..), fetchDuckDbTableRefs, refEquals, refToString)
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
import Set exposing (Set)
import Shared
import Task
import TypedSvg as S
import TypedSvg.Attributes as SA
import TypedSvg.Core as SC exposing (Svg)
import TypedSvg.Types as ST
import Utils exposing (send)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias RefString =
    String


type alias Model =
    { duckDbRefs : BackendData (List DuckDb.DuckDbRef)
    , duckDbRefMeta : Dict DuckDbRefString (List DuckDbColumnDescription)
    , selectedTableRef : Maybe DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe DuckDb.DuckDbRef
    , dragState : DragState
    , mouseEvent : Maybe Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : BackendData (List DimensionalModelRef)
    , proposedNewModelName : String
    , selectedDimensionalModel : Maybe DimensionalModel
    }


type DragState
    = Idle
    | DragInitiated DuckDb.DuckDbRef
    | Dragging DuckDb.DuckDbRef (Maybe Event) Event TableRenderInfo


type PageRenderStatus
    = AwaitingDomInfo
    | Ready LayoutInfo


init : ( Model, Effect Msg )
init =
    ( { duckDbRefs = NotAsked_
      , duckDbRefMeta = Dict.empty
      , selectedTableRef = Nothing
      , hoveredOnTableRef = Nothing
      , hoveredOnNodeTitle = Nothing
      , dragState = Idle
      , mouseEvent = Nothing
      , pageRenderStatus = AwaitingDomInfo
      , dimensionalModelRefs = Fetching_
      , viewPort = Nothing
      , proposedNewModelName = ""
      , selectedDimensionalModel = Nothing
      }
    , Effect.fromCmd <|
        Cmd.batch
            [ send FetchTableRefs
            , Task.perform GotViewport Browser.Dom.getViewport
            ]
    )


type DimType
    = Causal
    | NonCausal


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



-- TODO:
-- on select, check if we have, fetch from backend if we don't
-- fetch result from cache on backend
-- if exists send to frontend
-- update "Got" response


type Msg
    = FetchTableRefs
    | GotDimensionalModelRefs (List DimensionalModelRef)
    | GotDimensionalModel DimensionalModel
    | GotDuckDbTableRefsResponse (List DuckDb.DuckDbRef)
    | GotDuckDbCacheEntry DuckDbMetaDataCacheEntry
    | UserSelectedDimensionalModel DimensionalModelRef
    | UserToggledDuckDbRefSelection DuckDb.DuckDbRef
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

        GotDimensionalModel dimModel ->
            ( { model | selectedDimensionalModel = Just dimModel }, Effect.none )

        GotDuckDbTableRefsResponse refs ->
            ( { model | duckDbRefs = Success_ refs }, Effect.none )

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
                                    case model.selectedDimensionalModel of
                                        Nothing ->
                                            Nothing

                                        Just dimModel ->
                                            case Dict.get (refToString ref) dimModel.tableInfos of
                                                Nothing ->
                                                    Nothing

                                                Just ( renderInfo, _ ) ->
                                                    Just renderInfo
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

                newTableInfos : Dict DuckDbRefString ( TableRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) )
                newTableInfos =
                    case model.selectedDimensionalModel of
                        Nothing ->
                            Dict.empty

                        Just dimModel ->
                            case updatedTableInfo of
                                Nothing ->
                                    dimModel.tableInfos

                                Just updatedInfo_ ->
                                    case Dict.get (refToString updatedInfo_.ref) dimModel.tableInfos of
                                        Just ( renderInfo, assignment ) ->
                                            Dict.insert (refToString renderInfo.ref) ( updatedInfo_, assignment ) dimModel.tableInfos

                                        Nothing ->
                                            dimModel.tableInfos

                newDimModel : Maybe DimensionalModel
                newDimModel =
                    case model.selectedDimensionalModel of
                        Nothing ->
                            Nothing

                        Just dimModel ->
                            Just { dimModel | tableInfos = newTableInfos }
            in
            ( { model
                | mouseEvent = Just mouseEvent
                , dragState = newDragState
                , selectedDimensionalModel = newDimModel
              }
            , Effect.none
            )

        BeginNodeDrag ref ->
            ( { model | dragState = DragInitiated ref }, Effect.none )

        DragStoppedAt _ ->
            let
                cmd : Cmd msg
                cmd =
                    case model.selectedDimensionalModel of
                        Just dimModel ->
                            sendToBackend <| UpdateDimensionalModel dimModel

                        Nothing ->
                            Cmd.none
            in
            ( { model | dragState = Idle }, Effect.fromCmd cmd )

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
            ( { model | duckDbRefs = Fetching_ }, Effect.fromCmd <| sendToBackend Kimball_FetchDuckDbRefs )

        UserToggledDuckDbRefSelection ref ->
            let
                fetchCmd : Cmd frontendMsg
                fetchCmd =
                    -- fetch DuckDB metadata from the backend, if we need it client-side
                    case Dict.get (refToString ref) model.duckDbRefMeta of
                        Just _ ->
                            Cmd.none

                        Nothing ->
                            sendToBackend (FetchDuckDbMetaData ref)

                ( newDimModel, cmd ) =
                    case model.selectedDimensionalModel of
                        Nothing ->
                            -- menu to toggle ref selection is only rendered when there exists a selected model
                            -- this shouldn't happen; issue noop
                            ( Nothing, Cmd.none )

                        Just dimModel ->
                            let
                                startingPosition : PositionPx
                                startingPosition =
                                    { x = 100 * toFloat (Dict.size dimModel.tableInfos)
                                    , y = 100 * toFloat (Dict.size dimModel.tableInfos)
                                    }

                                newTableInfos : Dict DuckDbRefString ( TableRenderInfo, KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) )
                                newTableInfos =
                                    case Dict.get (refToString ref) dimModel.tableInfos of
                                        Just _ ->
                                            Dict.remove (refToString ref) dimModel.tableInfos

                                        Nothing ->
                                            let
                                                info : TableRenderInfo
                                                info =
                                                    { ref = ref
                                                    , pos = startingPosition
                                                    }

                                                kimballAssignment : KimballAssignment DuckDbRef_ (List DuckDbColumnDescription)
                                                kimballAssignment =
                                                    Unassigned (DuckDbTable ref) []
                                            in
                                            Dict.insert (refToString ref) ( info, kimballAssignment ) dimModel.tableInfos

                                newDimModel_ : DimensionalModel
                                newDimModel_ =
                                    { dimModel | tableInfos = newTableInfos }
                            in
                            ( Just newDimModel_, sendToBackend (UpdateDimensionalModel newDimModel_) )
            in
            -- If there is a selectedRef, by this point we've updated it, so we also must send a msg to Backend to
            -- update its knowledge of the dimensional model
            ( { model | selectedDimensionalModel = newDimModel }, Effect.batch <| [ Effect.fromCmd cmd, Effect.fromCmd fetchCmd ] )

        UserMouseEnteredTableRef ref ->
            ( { model | hoveredOnTableRef = Just ref }, Effect.none )

        UserMouseLeftTableRef ->
            ( { model | hoveredOnTableRef = Nothing }, Effect.none )

        UpdatedNewDimModelName newStr ->
            ( { model | proposedNewModelName = newStr }, Effect.none )

        UserCreatesNewDimensionalModel ref ->
            ( model, Effect.fromCmd <| sendToBackend (CreateNewDimensionalModel ref) )

        UserSelectedDimensionalModel ref ->
            ( model
            , Effect.batch
                [ Effect.fromCmd <| sendToBackend (FetchDimensionalModel ref)
                , Effect.fromCmd <| sendToBackend Kimball_FetchDuckDbRefs
                ]
            )

        GotDuckDbCacheEntry entry ->
            ( { model
                | duckDbRefMeta = Dict.insert (refToString entry.ref) entry.columnDescriptions model.duckDbRefMeta
              }
            , Effect.none
            )



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
    { title = "Kimball Assignments"
    , body =
        [ case model.pageRenderStatus of
            AwaitingDomInfo ->
                E.none

            Ready layoutInfo ->
                viewElements model layoutInfo
        ]
    }


viewDataSourceNode : Model -> TableRenderInfo -> KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) -> Svg Msg
viewDataSourceNode model renderInfo kimballAssignment =
    let
        ( table_, type_, backgroundColor ) =
            case kimballAssignment of
                Unassigned ref _ ->
                    case ref of
                        DuckDbView duckDbRef ->
                            ( duckDbRef, "Unassigned", Palette.orange_error_alert )

                        DuckDbTable duckDbRef ->
                            ( duckDbRef, "Unassigned", Palette.orange_error_alert )

                Fact ref _ ->
                    case ref of
                        DuckDbView duckDbRef ->
                            ( duckDbRef, "Fact", Palette.green_keylime )

                        DuckDbTable duckDbRef ->
                            ( duckDbRef, "Fact", Palette.green_keylime )

                Dimension ref _ ->
                    case ref of
                        DuckDbView duckDbRef ->
                            ( duckDbRef, "Dimension", Palette.lightBlue )

                        DuckDbTable duckDbRef ->
                            ( duckDbRef, "Dimension", Palette.lightBlue )

        colDescs : List DuckDbColumnDescription
        colDescs =
            case kimballAssignment of
                Unassigned _ columns ->
                    columns

                Fact _ columns ->
                    columns

                Dimension _ columns ->
                    columns

        title : String
        title =
            refToString table_

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
                            if refEquals renderInfo.ref ref_ then
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
                [ el
                    [ Border.widthEach { top = 0, left = 0, right = 0, bottom = 2 }
                    , Border.color Palette.black
                    , width fill
                    , Background.color titleBarBackgroundColor
                    , Events.onMouseEnter (UserMouseEnteredNodeTitleBar renderInfo.ref)
                    , Events.onMouseLeave UserMouseLeftNodeTitleBar
                    , Events.onMouseDown (BeginNodeDrag renderInfo.ref)
                    , paddingXY 0 5
                    ]
                  <|
                    row [ width fill, paddingXY 5 0 ]
                        [ el [ alignLeft ] (E.text <| type_ ++ ":")
                        , el [ alignLeft, moveRight 10 ] (E.text title)
                        ]
                , column
                    [ width fill
                    , height fill
                    ]
                  <|
                    List.map (\col -> viewColumn col) colDescs
                ]
    in
    SC.foreignObject
        [ SA.x (ST.px renderInfo.pos.x)
        , SA.y (ST.px renderInfo.pos.y)
        , SA.width (ST.px 250)
        , SA.height (ST.px 450)
        ]
        [ E.layoutWith { options = [ noStaticStyleSheet ] }
            [ Events.onMouseLeave ClearNodeHoverState
            ]
            element
        ]


viewCanvas : Model -> LayoutInfo -> Element Msg
viewCanvas model layoutInfo =
    let
        nodesContainer : List (Svg Msg)
        nodesContainer =
            case model.selectedDimensionalModel of
                Nothing ->
                    []

                Just dimModel ->
                    List.map (\( renderInfo, kimballAssignments ) -> renderHelp renderInfo kimballAssignments) (Dict.values dimModel.tableInfos)

        renderHelp : TableRenderInfo -> KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) -> Svg Msg
        renderHelp tblInfo assignments =
            viewDataSourceNode model tblInfo assignments
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
                nodesContainer


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
            , viewTableRefsContainer model
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

        selectedModelStr : String
        selectedModelStr =
            case model.selectedDimensionalModel of
                Nothing ->
                    "nothing"

                Just dimModel ->
                    dimModel.ref
    in
    column [ width fill, height fill, Border.width 1, Border.color Palette.darkishGrey ]
        [ E.text <| "events: " ++ mouseEventStr
        , E.text <| "drag state: " ++ dragStateStr
        , E.text <| "veiwPort: " ++ viewPortStr
        , E.text <| "dim model: " ++ selectedModelStr
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
                    column
                        [ width fill
                        ]
                        (List.map
                            (\ref ->
                                el
                                    [ paddingXY 5 3
                                    , Events.onClick (UserSelectedDimensionalModel ref)
                                    ]
                                    (E.text ref)
                            )
                            refs
                        )

                Error_ err ->
                    case err of
                        PlainMessage str ->
                            text str

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


viewTableRefsContainer : Model -> Element Msg
viewTableRefsContainer model =
    case model.selectedDimensionalModel of
        Nothing ->
            E.text "Select stuff"

        Just dimModel ->
            viewTableRefs model dimModel


viewTableRefs : Model -> DimensionalModel -> Element Msg
viewTableRefs model selectedDimModel =
    case model.duckDbRefs of
        NotAsked_ ->
            text "Didn't request data yet"

        Fetching_ ->
            text "Fetching db refs..."

        Success_ refs ->
            let
                refsSelector : List DuckDb.DuckDbRef -> Element Msg
                refsSelector refs_ =
                    let
                        backgroundColorFor : DuckDbRef -> Color
                        backgroundColorFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    Palette.white

                                Just ref_ ->
                                    if ref == ref_ then
                                        Palette.lightGrey

                                    else
                                        Palette.white

                        borderColorFor : DuckDbRef -> Color
                        borderColorFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    Palette.white

                                Just ref_ ->
                                    if ref == ref_ then
                                        Palette.darkishGrey

                                    else
                                        Palette.white

                        borderFor : DuckDbRef -> { top : number, left : number, right : number, bottom : number }
                        borderFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    { top = 1, left = 0, right = 0, bottom = 1 }

                                Just ref_ ->
                                    if ref == ref_ then
                                        { top = 1, left = 0, right = 0, bottom = 1 }

                                    else
                                        { top = 1, left = 0, right = 0, bottom = 1 }

                        innerBlobColorFor : DuckDbRef -> Color
                        innerBlobColorFor ref =
                            case Dict.member (refToString ref) selectedDimModel.tableInfos of
                                True ->
                                    Palette.green_keylime

                                False ->
                                    Palette.white

                        ui : DuckDb.DuckDbRef -> Element Msg
                        ui ref =
                            row
                                [ width E.fill
                                , paddingXY 0 2
                                , spacingXY 2 0
                                , Events.onClick <| UserToggledDuckDbRefSelection ref
                                , Events.onMouseEnter <| UserMouseEnteredTableRef ref
                                , Events.onMouseLeave <| UserMouseLeftTableRef
                                , Background.color (backgroundColorFor ref)
                                , Border.widthEach (borderFor ref)
                                , Border.color (borderColorFor ref)
                                ]
                                [ el
                                    [ width <| px 9
                                    , height <| px 9
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
                        List.map (\ref -> ui ref) refs_
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
                , refsSelector refs
                ]

        Error_ err ->
            case err of
                PlainMessage str ->
                    text str



-- end region view
