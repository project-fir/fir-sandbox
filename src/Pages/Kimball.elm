module Pages.Kimball exposing (Model, Msg(..), page)

import Bridge exposing (BackendData(..), BackendErrorMessage, DimensionalModelUpdate(..), DuckDbMetaDataCacheEntry, ToBackend(..))
import Browser.Dom
import Browser.Events as BE
import Dict exposing (Dict)
import DimensionalModel exposing (CardRenderInfo, DimModelDuckDbSourceInfo, DimensionalModel, DimensionalModelRef, EdgeLabel(..), KimballAssignment(..), NaivePairingStrategyResult(..), PositionPx, Reason(..), addEdge, addEdges, edge2Str, edgesOfType, naiveColumnPairingStrategy)
import DuckDb exposing (ColumnName, DuckDbColumn, DuckDbColumnDescription(..), DuckDbRef, DuckDbRefString, DuckDbRef_(..), PersistedDuckDbColumnDescription, fetchDuckDbTableRefs, refEquals, refToString)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Kimball exposing (Params)
import Graph
import Html.Events.Extra.Mouse as Mouse exposing (Event)
import Http
import Json.Decode as JD
import Lamdera exposing (sendToBackend)
import Page
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
import Ui exposing (ColorTheme, toAvhColor)
import Utils exposing (KeyCode, keyDecoder, send)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared.selectedTheme
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias RefString =
    String


type alias Model =
    { duckDbRefs : BackendData (List DuckDb.DuckDbRef)
    , selectedTableRef : Maybe DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe DuckDb.DuckDbRef
    , hoveredOnColumnWithinCard : Maybe DuckDbColumnDescription
    , partialEdgeInProgress : Maybe DuckDbColumnDescription
    , dragState : DragState
    , mouseEvent : Maybe Event
    , viewPort : Maybe Browser.Dom.Viewport
    , dimensionalModelRefs : BackendData (List DimensionalModelRef)
    , proposedNewModelName : String

    -- TODO: Having both selectedDimModel and pairingAlgoResult introduces duplicate copies of dimensionalModel
    --       Something to think about.. should all possible actions on dimModels be dimModel variants (similar to how I implemented
    --       the duckdb cache in Backend)?
    , selectedDimensionalModel : Maybe DimensionalModel
    , pairingAlgoResult : Maybe NaivePairingStrategyResult
    , dropdownState : Maybe DuckDbRef
    , inspectedColumn : Maybe DuckDbColumnDescription
    , columnPairingOperation : ColumnPairingOperation
    , downKeys : Set KeyCode
    , theme : ColorTheme
    , cursorMode : CursorMode
    }


type alias DropdownState =
    { duckDbRef : DuckDbRef
    }


type DragState
    = Idle
    | DragInitiated DuckDb.DuckDbRef
    | Dragging DuckDb.DuckDbRef (Maybe Event) Event CardRenderInfo


type PageRenderStatus
    = AwaitingDomInfo
    | Ready LayoutInfo


type CursorMode
    = DefaultCursor
    | ColumnPairingCursor


init : ColorTheme -> ( Model, Effect Msg )
init sharedTheme =
    ( { duckDbRefs = NotAsked_

      --, duckDbRefMeta = Dict.empty
      , selectedTableRef = Nothing
      , hoveredOnTableRef = Nothing
      , hoveredOnNodeTitle = Nothing
      , hoveredOnColumnWithinCard = Nothing
      , partialEdgeInProgress = Nothing
      , dragState = Idle
      , mouseEvent = Nothing
      , pageRenderStatus = AwaitingDomInfo
      , dimensionalModelRefs = Fetching_
      , viewPort = Nothing
      , proposedNewModelName = ""
      , selectedDimensionalModel = Nothing
      , pairingAlgoResult = Nothing
      , dropdownState = Nothing
      , inspectedColumn = Nothing
      , downKeys = Set.empty
      , columnPairingOperation = ColumnPairingIdle
      , theme = sharedTheme
      , cursorMode = DefaultCursor
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
    | UserSelectedDimensionalModel DimensionalModelRef
    | UserClickedDuckDbRef DuckDb.DuckDbRef
    | UserMouseEnteredTableRef DuckDb.DuckDbRef
    | UserClickedAttemptPairing DimensionalModelRef
    | UserToggledCardDropDown DuckDbRef
    | UserMouseLeftTableRef
    | UserMouseEnteredNodeTitleBar DuckDb.DuckDbRef
    | UserMouseEnteredColumnDescRow DuckDbColumnDescription
    | UserClickedColumnRow DuckDbColumnDescription
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
    | NoopKimball
    | UserClickedKimballAssignment DimensionalModelRef DuckDbRef (KimballAssignment DuckDbRef_ (List DuckDbColumnDescription))
    | UserClickedNub DuckDbColumnDescription
    | UserSelectedCursorMode CursorMode


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


type ColumnPairingOperation
    = ColumnPairingIdle
    | ColumnPairingListening
    | OriginSelected DuckDbColumnDescription
    | DestinationSelected DuckDbColumnDescription DuckDbColumnDescription


pairingState2Str : ColumnPairingOperation -> String
pairingState2Str pairingOp =
    case pairingOp of
        ColumnPairingIdle ->
            "idle"

        ColumnPairingListening ->
            "listening"

        OriginSelected from ->
            "origin selected"

        DestinationSelected from to ->
            "destination selected"


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserSelectedCursorMode mode ->
            let
                newPairingState =
                    case mode of
                        DefaultCursor ->
                            ColumnPairingIdle

                        ColumnPairingCursor ->
                            ColumnPairingListening
            in
            ( { model
                | cursorMode = mode
                , columnPairingOperation = newPairingState
              }
            , Effect.none
            )

        UserClickedColumnRow colDesc ->
            let
                newPairingOp : ColumnPairingOperation
                newPairingOp =
                    case model.columnPairingOperation of
                        ColumnPairingIdle ->
                            ColumnPairingIdle

                        ColumnPairingListening ->
                            OriginSelected colDesc

                        OriginSelected origin ->
                            DestinationSelected origin colDesc

                        DestinationSelected _ _ ->
                            ColumnPairingIdle

                effect =
                    case newPairingOp of
                        DestinationSelected from to ->
                            case model.selectedDimensionalModel of
                                Just dimModel ->
                                    let
                                        newGraph =
                                            -- NB: Add two edges, (from, to) and (to, from)
                                            addEdge (addEdge dimModel.graph ( from, to ) Joinable) ( to, from ) Joinable
                                    in
                                    Effect.fromCmd <| sendToBackend (UpdateDimensionalModel (UpdateGraph dimModel.ref newGraph))

                                Nothing ->
                                    Effect.none

                        _ ->
                            Effect.none
            in
            case model.cursorMode of
                DefaultCursor ->
                    ( model, Effect.none )

                ColumnPairingCursor ->
                    ( { model
                        | inspectedColumn = Just colDesc
                        , columnPairingOperation = newPairingOp
                      }
                    , effect
                    )

        UserClickedKimballAssignment dimRef duckDbRef assignment ->
            -- NB: We have the "side effect" of closing the dropdown menu
            ( { model | dropdownState = Nothing }
            , Effect.fromCmd (sendToBackend (UpdateDimensionalModel (UpdateAssignment dimRef duckDbRef assignment)))
            )

        NoopKimball ->
            ( model, Effect.none )

        UserToggledCardDropDown duckDbRef ->
            case model.dropdownState of
                Nothing ->
                    ( { model | dropdownState = Just duckDbRef }, Effect.none )

                Just _ ->
                    ( { model | dropdownState = Nothing }, Effect.none )

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
                ( newDragState, newDimModel ) =
                    case model.dragState of
                        Idle ->
                            ( Idle, Nothing )

                        DragInitiated ref ->
                            let
                                anchoredInfo : Maybe CardRenderInfo
                                anchoredInfo =
                                    case model.selectedDimensionalModel of
                                        Nothing ->
                                            Nothing

                                        Just dimModel ->
                                            case Dict.get (refToString ref) dimModel.tableInfos of
                                                Nothing ->
                                                    Nothing

                                                Just info ->
                                                    Just info.renderInfo
                            in
                            case anchoredInfo of
                                Nothing ->
                                    ( Idle, Nothing )

                                Just anchoredInfo_ ->
                                    ( Dragging ref Nothing mouseEvent anchoredInfo_, model.selectedDimensionalModel )

                        Dragging ref firstEvent oldEvent anchoredInfo ->
                            case firstEvent of
                                Nothing ->
                                    ( Dragging ref (Just oldEvent) mouseEvent anchoredInfo, model.selectedDimensionalModel )

                                Just firstEvent_ ->
                                    let
                                        dx : Float
                                        dx =
                                            Tuple.first mouseEvent.clientPos - Tuple.first firstEvent_.clientPos

                                        dy : Float
                                        dy =
                                            Tuple.second mouseEvent.clientPos - Tuple.second firstEvent_.clientPos

                                        updatedInfo : CardRenderInfo
                                        updatedInfo =
                                            { anchoredInfo
                                                | pos =
                                                    { x = anchoredInfo.pos.x + dx
                                                    , y = anchoredInfo.pos.y + dy
                                                    }
                                            }

                                        -- NB: It may strike as odd that this is so nested, but think of it as the
                                        --     only path that has updated CardRenderInfo computed, so is therefore
                                        --     the only path that results in a changed DimensionalModel
                                        updatedDimModel : Maybe DimensionalModel
                                        updatedDimModel =
                                            case model.selectedDimensionalModel of
                                                Nothing ->
                                                    Nothing

                                                Just dimModel ->
                                                    case Dict.get (refToString ref) dimModel.tableInfos of
                                                        Just info ->
                                                            let
                                                                newInfo : DimModelDuckDbSourceInfo
                                                                newInfo =
                                                                    { info | renderInfo = updatedInfo }

                                                                newTableInfos : Dict DuckDbRefString DimModelDuckDbSourceInfo
                                                                newTableInfos =
                                                                    Dict.insert (refToString ref) newInfo dimModel.tableInfos
                                                            in
                                                            Just { dimModel | tableInfos = newTableInfos }

                                                        Nothing ->
                                                            Just dimModel
                                    in
                                    ( Dragging ref (Just firstEvent_) mouseEvent anchoredInfo, updatedDimModel )
            in
            ( { model
                | mouseEvent = Just mouseEvent
                , dragState = newDragState
                , selectedDimensionalModel = newDimModel
              }
            , Effect.none
            )

        BeginNodeDrag ref ->
            case model.cursorMode of
                DefaultCursor ->
                    ( { model | dragState = DragInitiated ref }, Effect.none )

                _ ->
                    ( model, Effect.none )

        DragStoppedAt _ ->
            -- NB: During a drag, client-side model is updated, but since those events are so frequent, we don't
            -- update the backend. So we update the backend from the current model data here.
            let
                ref : Maybe DuckDbRef
                ref =
                    case model.dragState of
                        Idle ->
                            Nothing

                        DragInitiated duckDbRef ->
                            Just duckDbRef

                        Dragging duckDbRef _ _ _ ->
                            Just duckDbRef

                cmd : Cmd msg
                cmd =
                    case ref of
                        Just ref_ ->
                            case model.selectedDimensionalModel of
                                Just dimModel ->
                                    let
                                        newPos : Maybe PositionPx
                                        newPos =
                                            case Dict.get (refToString ref_) dimModel.tableInfos of
                                                Just info ->
                                                    Just info.renderInfo.pos

                                                Nothing ->
                                                    Nothing
                                    in
                                    case newPos of
                                        Just newPos_ ->
                                            sendToBackend <| UpdateDimensionalModel (UpdateNodePosition dimModel.ref ref_ newPos_)

                                        Nothing ->
                                            Cmd.none

                                Nothing ->
                                    Cmd.none

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

        ClearNodeHoverState ->
            ( { model
                | hoveredOnNodeTitle = Nothing
                , hoveredOnColumnWithinCard = Nothing
              }
            , Effect.none
            )

        UserMouseEnteredColumnDescRow colDesc ->
            ( { model | hoveredOnColumnWithinCard = Just colDesc }, Effect.none )

        UserClickedNub colDesc ->
            let
                ( newPartialEdge, cmd ) =
                    case model.partialEdgeInProgress of
                        Just colDesc_ ->
                            case colDesc of
                                Persisted_ perCol ->
                                    case colDesc_ of
                                        Persisted_ perCol_ ->
                                            case perCol_.name == perCol.name && perCol_.parentRef == perCol.parentRef of
                                                True ->
                                                    -- User clicked same nub as already selected in model.partialEdgeInProgress
                                                    ( Nothing, Cmd.none )

                                                False ->
                                                    case model.selectedDimensionalModel of
                                                        -- User clicked another nub, reset partial selection to Nothing
                                                        -- but Fire event to backend, updating graph
                                                        Just dimModel ->
                                                            let
                                                                -- NB: Add both directions, manually unpacked here
                                                                newGraph =
                                                                    addEdges dimModel.graph [ ( colDesc_, colDesc, Joinable ), ( colDesc, colDesc_, Joinable ) ]
                                                            in
                                                            ( Nothing, sendToBackend (UpdateDimensionalModel (UpdateGraph dimModel.ref newGraph)) )

                                                        Nothing ->
                                                            -- degenerate case, we should never get here without having a dim model selected
                                                            ( Nothing, Cmd.none )

                                        Computed_ _ ->
                                            -- TODO: Computed column support
                                            ( Just colDesc, Cmd.none )

                                Computed_ _ ->
                                    -- TODO: Computed column support
                                    ( Just colDesc, Cmd.none )

                        Nothing ->
                            ( Just colDesc, Cmd.none )
            in
            ( { model | partialEdgeInProgress = newPartialEdge }, Effect.fromCmd cmd )

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

        UserClickedDuckDbRef duckDbRef ->
            let
                cmd =
                    case model.selectedDimensionalModel of
                        Nothing ->
                            -- menu to toggle ref selection is only rendered when there exists a selected model
                            -- this shouldn't happen; issue noop
                            Cmd.none

                        Just currentDimModel ->
                            -- NB: The user action of clicking a ref may result in either 1) creation of a new
                            -- entry in our dimensional model, or 2) toggling its presence in the model
                            -- a sort-of soft-delete to toggle visual card without destroying any user modifications
                            case Dict.get (refToString duckDbRef) currentDimModel.tableInfos of
                                Just _ ->
                                    sendToBackend (UpdateDimensionalModel (ToggleIncludedNode currentDimModel.ref duckDbRef))

                                Nothing ->
                                    sendToBackend (UpdateDimensionalModel (AddDuckDbRefToModel currentDimModel.ref duckDbRef))
            in
            -- If there is a selectedRef, by this point we've updated it, so we also must send a msg to Backend to
            -- update its knowledge of the dimensional model
            ( model, Effect.fromCmd cmd )

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

        UserClickedAttemptPairing dimRef ->
            let
                ( newDimModel, pairingStatus ) =
                    case model.selectedDimensionalModel of
                        Nothing ->
                            ( Nothing, Nothing )

                        Just dimModel ->
                            case dimModel.ref == dimRef of
                                True ->
                                    case naiveColumnPairingStrategy dimModel of
                                        DimensionalModel.Success pairedDimModel ->
                                            ( Just pairedDimModel, Just <| DimensionalModel.Success pairedDimModel )

                                        DimensionalModel.Fail reason ->
                                            case reason of
                                                -- Note, we failed to pair the graph, but we still have the model
                                                -- so just return what we already have, with the error reason message
                                                AllInputTablesMustBeAssigned ->
                                                    ( Just dimModel, Just <| DimensionalModel.Fail AllInputTablesMustBeAssigned )

                                                InputMustContainAtLeastOneFactTable ->
                                                    ( Just dimModel, Just <| DimensionalModel.Fail InputMustContainAtLeastOneFactTable )

                                                InputMustContainAtLeastOneDimensionTable ->
                                                    ( Just dimModel, Just <| DimensionalModel.Fail InputMustContainAtLeastOneDimensionTable )

                                False ->
                                    ( Nothing, Nothing )

                cmd : Cmd msg
                cmd =
                    case pairingStatus of
                        Just status ->
                            case status of
                                DimensionalModel.Success pairedDimModel ->
                                    sendToBackend <| UpdateDimensionalModel (FullReplacement pairedDimModel.ref pairedDimModel)

                                DimensionalModel.Fail _ ->
                                    Cmd.none

                        Nothing ->
                            Cmd.none
            in
            ( { model
                | selectedDimensionalModel = newDimModel
                , pairingAlgoResult = pairingStatus
              }
            , Effect.fromCmd cmd
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
    -- Always listen to Browser events, and key strokes, but only listen to drag events if we believe we're dragging!
    Sub.batch
        ([ BE.onResize GotResizeEvent
         ]
            ++ dragSubs
        )



-- begin region view


view : Model -> View Msg
view model =
    { title = "Kimball Assignments"
    , body =
        case model.pageRenderStatus of
            AwaitingDomInfo ->
                E.none

            Ready layoutInfo ->
                viewElements model layoutInfo
    }


viewDataSourceCard : Model -> DimensionalModelRef -> CardRenderInfo -> KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) -> Svg Msg
viewDataSourceCard model dimModelRef renderInfo kimballAssignment =
    let
        ( table_, type_, computedBackgroundColor ) =
            case kimballAssignment of
                Unassigned ref _ ->
                    case ref of
                        DuckDbView duckDbRef ->
                            ( duckDbRef, "Unassigned", model.theme.debugWarn )

                        DuckDbTable duckDbRef ->
                            ( duckDbRef, "Unassigned", model.theme.debugWarn )

                Fact ref _ ->
                    case ref of
                        DuckDbView duckDbRef ->
                            ( duckDbRef, "Fact", model.theme.primary1 )

                        DuckDbTable duckDbRef ->
                            ( duckDbRef, "Fact", model.theme.primary1 )

                Dimension ref _ ->
                    case ref of
                        DuckDbView duckDbRef ->
                            ( duckDbRef, "Dimension", model.theme.primary2 )

                        DuckDbTable duckDbRef ->
                            ( duckDbRef, "Dimension", model.theme.primary2 )

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

        viewRowForColumnDesc : DuckDbColumnDescription -> Element Msg
        viewRowForColumnDesc col =
            let
                rowBackgroundColor : Color
                rowBackgroundColor =
                    case model.hoveredOnColumnWithinCard of
                        Nothing ->
                            -- TODO: Do I need a transparent entry in ColorTheme?
                            computedBackgroundColor

                        Just col_ ->
                            case col_ of
                                Persisted_ perCol_ ->
                                    case col of
                                        Persisted_ perCol ->
                                            case perCol.name == perCol_.name && perCol_.parentRef == perCol.parentRef of
                                                True ->
                                                    -- TODO: Do I need a darken entry in ColorTheme?
                                                    model.theme.secondary

                                                False ->
                                                    computedBackgroundColor

                                        Computed_ _ ->
                                            -- TODO: Computed column support
                                            computedBackgroundColor

                                Computed_ _ ->
                                    -- TODO: Computed column support
                                    computedBackgroundColor

                name : String
                name =
                    case col of
                        Persisted_ desc ->
                            desc.name

                        Computed_ desc ->
                            desc.name

                viewNub : Element Msg
                viewNub =
                    el
                        [ width <| px 10
                        , height <| px 10
                        , Border.width 1
                        , Background.color model.theme.background
                        , Events.onClick (UserClickedNub col)
                        ]
                        E.none
            in
            row
                [ width E.fill
                , moveRight 3
                , paddingXY 5 2
                , spacingXY 4 0
                , Events.onMouseEnter (UserMouseEnteredColumnDescRow col)
                , Events.onClick (UserClickedColumnRow col)
                , Background.color rowBackgroundColor
                ]
                [ viewNub
                , text name
                , el [ alignRight ] viewNub
                ]

        viewCardElements : Element Msg
        viewCardElements =
            let
                titleBarBackgroundColor : Color
                titleBarBackgroundColor =
                    case model.hoveredOnNodeTitle of
                        Nothing ->
                            computedBackgroundColor

                        Just ref_ ->
                            if refEquals renderInfo.ref ref_ then
                                model.theme.secondary

                            else
                                computedBackgroundColor

                viewTitleBar : Element Msg
                viewTitleBar =
                    el
                        [ Border.widthEach { top = 0, left = 0, right = 0, bottom = 2 }
                        , Border.color model.theme.secondary
                        , width fill
                        , Background.color titleBarBackgroundColor
                        , paddingXY 0 0
                        , Events.onClick (UserToggledCardDropDown renderInfo.ref)
                        ]
                    <|
                        row
                            [ width fill
                            , height fill
                            , paddingXY 5 0
                            ]
                            [ el [ alignLeft ] (E.text <| type_ ++ ":")

                            -- some useful characters to keep handy here:
                            -- ᐁ ᐅ ▼ ▶
                            --
                            , column []
                                [ el
                                    [ Border.width 1
                                    , Border.color model.theme.black
                                    , padding 2
                                    ]
                                    (case model.dropdownState of
                                        Nothing ->
                                            el [] (E.text "▼")

                                        Just duckDbRef ->
                                            case renderInfo.ref == duckDbRef of
                                                True ->
                                                    el
                                                        [ E.onRight
                                                            (column
                                                                [ Border.color model.theme.secondary
                                                                , Border.width 1
                                                                , Background.color model.theme.background
                                                                , spacing 3
                                                                ]
                                                                [ el
                                                                    [ width fill
                                                                    , height fill
                                                                    , Events.onClick (UserClickedKimballAssignment dimModelRef renderInfo.ref (Unassigned (DuckDbTable renderInfo.ref) colDescs))
                                                                    ]
                                                                  <|
                                                                    E.text "Unassigned"
                                                                , el
                                                                    [ width fill
                                                                    , height fill
                                                                    , Events.onClick (UserClickedKimballAssignment dimModelRef renderInfo.ref (Dimension (DuckDbTable renderInfo.ref) colDescs))
                                                                    ]
                                                                  <|
                                                                    E.text "Dimension"
                                                                , el
                                                                    [ width fill
                                                                    , height fill
                                                                    , Events.onClick (UserClickedKimballAssignment dimModelRef renderInfo.ref (Fact (DuckDbTable renderInfo.ref) colDescs))
                                                                    ]
                                                                  <|
                                                                    E.text "Fact"
                                                                ]
                                                            )
                                                        ]
                                                        (el [] <| E.text "▶")

                                                False ->
                                                    E.text "default elements"
                                    )
                                ]
                            , el [ alignLeft, moveRight 10 ] (E.text title)
                            ]
            in
            column
                [ width (px <| round (erdCardWidth - 1.0))
                , height (px <| round (erdCardHeight - 1.0))
                , Border.color model.theme.secondary
                , Border.width 1
                , Border.rounded 5
                , padding 2
                , Background.color computedBackgroundColor
                , Font.size 14
                , Events.onMouseEnter (UserMouseEnteredNodeTitleBar renderInfo.ref)
                ]
                [ viewTitleBar
                , column
                    [ width (px <| round (erdCardWidth - 10.0))
                    , height (px <| round (erdCardHeight - titleBarHeight - 0))
                    , Events.onMouseDown (BeginNodeDrag renderInfo.ref)
                    ]
                  <|
                    List.map (\col -> viewRowForColumnDesc col) colDescs
                ]

        erdCardWidth : Float
        erdCardWidth =
            250

        titleBarHeight : Float
        titleBarHeight =
            29.0

        erdCardHeight : Float
        erdCardHeight =
            titleBarHeight + (18.0 * toFloat (List.length colDescs))
    in
    SC.foreignObject
        [ SA.x (ST.px renderInfo.pos.x)
        , SA.y (ST.px renderInfo.pos.y)
        , SA.width (ST.px erdCardWidth)
        , SA.height (ST.px erdCardHeight)
        ]
        [ E.layoutWith { options = [ noStaticStyleSheet ] }
            [ Events.onMouseLeave ClearNodeHoverState
            ]
            viewCardElements
        ]


viewCanvas : Model -> LayoutInfo -> Element Msg
viewCanvas model layoutInfo =
    let
        lines : List (Svg Msg)
        lines =
            [ S.line
                [ SA.x1 (ST.px 428)
                , SA.y1 (ST.px 173)
                , SA.x2 (ST.px 725)
                , SA.y2 (ST.px 147)
                , SA.stroke (ST.Paint (toAvhColor model.theme.black))
                ]
                []
            ]

        erdCardsSvgNode : List (Svg Msg)
        erdCardsSvgNode =
            let
                renderHelp : DimModelDuckDbSourceInfo -> DimensionalModelRef -> Svg Msg
                renderHelp info dimModelRef =
                    viewDataSourceCard model dimModelRef info.renderInfo info.assignment
            in
            case model.selectedDimensionalModel of
                Nothing ->
                    []

                Just dimModel ->
                    List.filterMap
                        (\info ->
                            case info.isIncluded of
                                True ->
                                    Just <| renderHelp info dimModel.ref

                                False ->
                                    Nothing
                        )
                        (Dict.values dimModel.tableInfos)
    in
    el
        [ Border.width 1
        , Border.color model.theme.secondary
        , Border.rounded 5
        , Events.onMouseLeave TerminateDrags
        , centerY
        , centerX
        , Background.color model.theme.background
        ]
    <|
        E.html <|
            S.svg
                [ SA.width (ST.px layoutInfo.canvasElementWidth)
                , SA.height (ST.px layoutInfo.canvasElementHeight)
                , SA.viewBox layoutInfo.viewBoxXMin layoutInfo.viewBoxYMin layoutInfo.viewBoxWidth layoutInfo.viewBoxHeight
                ]
                (erdCardsSvgNode ++ lines)


viewControlPanel : Model -> Element Msg
viewControlPanel model =
    let
        viewViewBoxControls : Element Msg
        viewViewBoxControls =
            row
                [ centerX
                , Background.color model.theme.background
                , height fill
                , paddingXY 5 0
                , Font.size 24
                , spacing 5
                ]
                [ el [ centerX, Border.width 1, Background.color model.theme.deadspace, Border.color model.theme.black, Events.onClick <| SvgViewBoxTransform (Zoom 0.1) ] <| E.text "+"
                , el [ centerX, Border.width 1, Background.color model.theme.deadspace, Border.color model.theme.black, Events.onClick <| SvgViewBoxTransform (Zoom -0.1) ] <| E.text "-"
                , el [ centerX, Border.width 1, Background.color model.theme.deadspace, Border.color model.theme.black, Events.onClick <| SvgViewBoxTransform (Translation -20 0) ] <| E.text "ᐊ"
                , el [ centerX, Border.width 1, Background.color model.theme.deadspace, Border.color model.theme.black, Events.onClick <| SvgViewBoxTransform (Translation 20 0) ] <| E.text "ᐅ"
                , el [ centerX, Border.width 1, Background.color model.theme.deadspace, Border.color model.theme.black, Events.onClick <| SvgViewBoxTransform (Translation 0 -20) ] <| E.text "ᐃ"
                , el [ centerX, Border.width 1, Background.color model.theme.deadspace, Border.color model.theme.black, Events.onClick <| SvgViewBoxTransform (Translation 0 20) ] <| E.text "ᐁ"
                ]

        onPress : Maybe Msg
        onPress =
            case model.selectedDimensionalModel of
                Just dimModel ->
                    Just <| UserClickedAttemptPairing dimModel.ref

                Nothing ->
                    Nothing

        viewCursorToolBar : Element Msg
        viewCursorToolBar =
            let
                iconSizePx =
                    25
            in
            row
                [ centerX
                , centerY
                , moveRight 10
                , height fill
                , paddingXY 10 0
                , Font.size 12
                , spacing 10
                ]
                [ el
                    [ centerX
                    , Border.width 1
                    , Background.color
                        (case model.cursorMode of
                            DefaultCursor ->
                                model.theme.secondary

                            _ ->
                                model.theme.background
                        )
                    , Border.color model.theme.black
                    , Events.onClick <| UserSelectedCursorMode DefaultCursor
                    ]
                    (E.image [ height (px iconSizePx), width (px iconSizePx) ] { src = "./default-cursor.png", description = "standard mouse cursor" })
                , el
                    [ centerX
                    , centerY
                    , Border.width 1
                    , Background.color
                        (case model.cursorMode of
                            ColumnPairingCursor ->
                                model.theme.secondary

                            _ ->
                                model.theme.background
                        )
                    , Border.color model.theme.black
                    , Events.onClick <| UserSelectedCursorMode ColumnPairingCursor
                    ]
                    (E.image [ height (px iconSizePx), width (px iconSizePx) ] { src = "./graph-builder-cursor.png", description = "graph building cursor" })
                ]
    in
    row
        [ width fill
        , height (px 40)
        , Font.size 30
        , Border.width 1
        , Background.color model.theme.background
        , Border.color model.theme.secondary
        , Border.rounded 5
        , spacing 6
        ]
        [ viewCursorToolBar
        , viewViewBoxControls
        ]


viewElements : Model -> LayoutInfo -> Element Msg
viewElements model layoutInfo =
    row
        [ width fill
        , height fill
        , centerX
        , centerY
        , Background.color model.theme.deadspace
        ]
        [ column
            [ height fill
            , width (px layoutInfo.mainPanelWidth)
            , paddingXY 0 3
            , Background.color model.theme.deadspace
            , centerX
            ]
            [ viewCanvas model layoutInfo
            , viewControlPanel model
            ]
        , column
            [ height fill
            , width (px layoutInfo.sidePanelWidth)
            , Border.width 1
            , Background.color model.theme.background
            , Border.color model.theme.secondary
            , clipX
            , scrollbarX
            , alignRight
            ]
            [ viewDimensionalModelRefs model
            , viewTableRefsContainer model
            , viewColumnInspectorPanel model
            , viewMouseEventsDebugInfo model
            ]
        ]


viewColumnInspectorPanel : Model -> Element Msg
viewColumnInspectorPanel model =
    let
        text : Maybe String
        text =
            case model.inspectedColumn of
                Just colDesc ->
                    case colDesc of
                        Persisted_ colDesc_ ->
                            case colDesc_.parentRef of
                                DuckDbView ref ->
                                    Just <| refToString ref ++ "::" ++ colDesc_.name

                                DuckDbTable ref ->
                                    Just <| refToString ref ++ "::" ++ colDesc_.name

                        Computed_ computedDuckDbColumnDescription ->
                            -- TODO: Computed support
                            Nothing

                Nothing ->
                    Nothing

        info : Element Msg
        info =
            case text of
                Nothing ->
                    E.none

                Just t ->
                    E.text t
    in
    column [ width fill, height fill, Border.width 1, Border.color model.theme.secondary, spacing 5 ]
        [ E.text "Column Inspector:"
        , info
        ]


viewMouseEventsDebugInfo : Model -> Element Msg
viewMouseEventsDebugInfo model =
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

        cursorMode2Str : CursorMode -> String
        cursorMode2Str mode =
            case mode of
                DefaultCursor ->
                    "Default Cursor"

                ColumnPairingCursor ->
                    "Column Pairing Cursor"
    in
    column
        [ padding 2
        , width fill
        , height fill
        , Border.width 1
        , Border.color model.theme.secondary
        , spacing 5
        , clipY
        , scrollbarY
        ]
        [ E.none
        , el [ Font.bold ] (E.text "Debug info:")
        , el [ Font.bold ] (E.text "General state:")
        , paragraph [ padding 3 ]
            [ E.text ("dim model: " ++ selectedModelStr)
            ]
        , paragraph [ padding 3 ]
            [ E.text ("pairing op: " ++ pairingState2Str model.columnPairingOperation)
            ]
        , paragraph [ padding 3 ]
            [ E.text <| "veiwPort: " ++ viewPortStr
            ]
        , el [ Font.bold ] (E.text "Mouse Events:")
        , paragraph [ padding 3 ]
            [ E.text <| "most recent event coord: " ++ mouseEventStr
            ]
        , paragraph [ padding 3 ]
            [ E.text <| "drag state: " ++ dragStateStr
            ]
        , paragraph [ padding 3 ]
            [ E.text <| "cursor mode: " ++ cursorMode2Str model.cursorMode
            ]
        , el [ Font.bold ] (E.text "Graph Data:")
        , paragraph [ padding 3 ]
            (List.map (\edge -> E.text <| edge2Str edge ++ "\n")
                (case model.selectedDimensionalModel of
                    Just dimModel ->
                        edgesOfType dimModel.graph Joinable

                    Nothing ->
                        []
                )
            )
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
                    text err

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
                            , Border.color model.theme.black
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
                                    model.theme.background

                                Just ref_ ->
                                    if ref == ref_ then
                                        model.theme.secondary

                                    else
                                        model.theme.background

                        borderColorFor : DuckDbRef -> Color
                        borderColorFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    model.theme.background

                                Just ref_ ->
                                    if ref == ref_ then
                                        model.theme.secondary

                                    else
                                        model.theme.background

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
                            case Dict.get (refToString ref) selectedDimModel.tableInfos of
                                Just info ->
                                    case info.isIncluded of
                                        True ->
                                            model.theme.secondary

                                        False ->
                                            model.theme.background

                                Nothing ->
                                    model.theme.background

                        ui : DuckDb.DuckDbRef -> Element Msg
                        ui ref =
                            row
                                [ width E.fill
                                , paddingXY 0 2
                                , spacingXY 2 0
                                , Events.onClick <| UserClickedDuckDbRef ref
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
                , Border.color model.theme.secondary
                , clipX
                , scrollbarX
                , clipY
                , scrollbarY
                ]
                [ text "DuckDB Refs:"
                , refsSelector refs
                ]

        Error_ err ->
            text err



-- end region view
