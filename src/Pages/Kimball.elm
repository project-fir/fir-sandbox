module Pages.Kimball exposing (Model, Msg(..), page)

import Bridge exposing (BackendData(..), BackendErrorMessage, DimensionalModelUpdate(..), DuckDbMetaDataCacheEntry, ToBackend(..))
import Browser.Dom
import Browser.Events as BE
import Dict exposing (Dict)
import DimensionalModel exposing (CardRenderInfo, DimModelDuckDbSourceInfo, DimensionalModel, DimensionalModelRef, KimballAssignment(..), NaivePairingStrategyResult(..), PositionPx, Reason(..), naiveColumnPairingStrategy)
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

    --, duckDbRefMeta : Dict DuckDbRefString (List DuckDbColumnDescription)
    , selectedTableRef : Maybe DuckDb.DuckDbRef
    , hoveredOnTableRef : Maybe DuckDb.DuckDbRef
    , pageRenderStatus : PageRenderStatus
    , hoveredOnNodeTitle : Maybe DuckDb.DuckDbRef
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


init : ( Model, Effect Msg )
init =
    ( { duckDbRefs = NotAsked_

      --, duckDbRefMeta = Dict.empty
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
      , pairingAlgoResult = Nothing
      , dropdownState = Nothing
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


type SvgViewBoxTransformation
    = Zoom Float
    | Translation Float Float


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
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
            ( { model | dragState = DragInitiated ref }, Effect.none )

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


viewDataSourceNode : Model -> DimensionalModelRef -> CardRenderInfo -> KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) -> Svg Msg
viewDataSourceNode model dimModelRef renderInfo kimballAssignment =
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

        viewCardElements : Element Msg
        viewCardElements =
            let
                titleBarBackgroundColor : Color
                titleBarBackgroundColor =
                    case model.hoveredOnNodeTitle of
                        Nothing ->
                            backgroundColor

                        Just ref_ ->
                            if refEquals renderInfo.ref ref_ then
                                Palette.darkishGrey

                            else
                                backgroundColor

                viewTitleBar : Element Msg
                viewTitleBar =
                    el
                        [ Border.widthEach { top = 0, left = 0, right = 0, bottom = 2 }
                        , Border.color Palette.black
                        , width fill
                        , Background.color titleBarBackgroundColor

                        --, Events.onMouseEnter (UserMouseEnteredNodeTitleBar renderInfo.ref)
                        , Events.onMouseLeave UserMouseLeftNodeTitleBar
                        , Events.onMouseDown (BeginNodeDrag renderInfo.ref)
                        , paddingXY 0 5
                        ]
                    <|
                        row [ width fill, paddingXY 5 0 ]
                            [ el [ alignLeft ] (E.text <| type_ ++ ":")

                            -- some useful characters to keep handy here:
                            -- ᐁ ᐅ ▼ ▶
                            --
                            , column []
                                [ el
                                    [ Border.width 1
                                    , Border.color Palette.black
                                    , padding 2

                                    --, inFront
                                    ]
                                    (case model.dropdownState of
                                        Nothing ->
                                            el [ Events.onClick <| UserToggledCardDropDown renderInfo.ref ] (E.text "▼")

                                        Just duckDbRef ->
                                            case renderInfo.ref == duckDbRef of
                                                True ->
                                                    el
                                                        [ E.onRight
                                                            (column
                                                                [ Border.color Palette.lightGrey
                                                                , Border.width 1
                                                                , Background.color Palette.lightBlue
                                                                , spacing 3
                                                                ]
                                                                [ el [ Events.onClick (UserClickedKimballAssignment dimModelRef renderInfo.ref (Unassigned (DuckDbTable renderInfo.ref) colDescs)) ] <| E.text "Unassigned"
                                                                , el [ Events.onClick (UserClickedKimballAssignment dimModelRef renderInfo.ref (Dimension (DuckDbTable renderInfo.ref) colDescs)) ] <| E.text "Dimension"
                                                                , el [ Events.onClick (UserClickedKimballAssignment dimModelRef renderInfo.ref (Fact (DuckDbTable renderInfo.ref) colDescs)) ] <| E.text "Fact"
                                                                ]
                                                            )
                                                        ]
                                                        (el [ Events.onClick <| UserToggledCardDropDown renderInfo.ref ] <| E.text "▶")

                                                False ->
                                                    E.text "default elements"
                                    )
                                ]
                            , el [ alignLeft, moveRight 10 ] (E.text title)
                            ]
            in
            column
                [ width fill
                , height fill
                , Border.color Palette.black
                , Border.width 1
                , padding 2
                , Background.color backgroundColor
                , Font.size 14
                ]
                [ viewTitleBar
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
            viewCardElements
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
                    List.filterMap
                        (\info ->
                            case info.isIncluded of
                                True ->
                                    Just <| renderHelp info dimModel.ref

                                False ->
                                    Nothing
                        )
                        (Dict.values dimModel.tableInfos)

        renderHelp : DimModelDuckDbSourceInfo -> DimensionalModelRef -> Svg Msg
        renderHelp info dimModelRef =
            viewDataSourceNode model dimModelRef info.renderInfo info.assignment
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


viewControlPanel : Model -> Element Msg
viewControlPanel model =
    let
        viewViewBoxControls : Element Msg
        viewViewBoxControls =
            row
                [ centerX
                , Border.width 1
                , Border.color Palette.black
                , height fill
                , paddingXY 5 0
                , Font.size 24
                , spacing 5
                ]
                [ el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Zoom 0.1) ] <| E.text "+"
                , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Zoom -0.1) ] <| E.text "-"
                , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation -20 0) ] <| E.text "ᐊ"
                , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation 20 0) ] <| E.text "ᐅ"
                , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation 0 -20) ] <| E.text "ᐃ"
                , el [ centerX, Border.width 1, Border.color Palette.black, Events.onClick <| SvgViewBoxTransform (Translation 0 20) ] <| E.text "ᐁ"
                ]

        onPress : Maybe Msg
        onPress =
            case model.selectedDimensionalModel of
                Just dimModel ->
                    Just <| UserClickedAttemptPairing dimModel.ref

                Nothing ->
                    Nothing

        viewGraphControlPanel : Element Msg
        viewGraphControlPanel =
            row
                [ centerX
                , moveRight 10
                , height fill
                , Border.color Palette.black
                , paddingXY 10 0
                , Border.width 1
                , Font.size 12
                , spacing 10
                ]
                [ Input.button [ alignRight ]
                    { label =
                        el
                            [ Border.width 1
                            , Border.rounded 2
                            , Background.color Palette.lightGrey
                            , Border.color Palette.darkishGrey
                            , padding 2
                            , Font.size 14
                            ]
                            (E.text "Pair columns")
                    , onPress = onPress
                    }
                , el []
                    (text
                        (case model.pairingAlgoResult of
                            Just pairingResult ->
                                case pairingResult of
                                    DimensionalModel.Success _ ->
                                        "pairing was a success!"

                                    Fail reason ->
                                        case reason of
                                            AllInputTablesMustBeAssigned ->
                                                "all tables must be given an assignment"

                                            InputMustContainAtLeastOneFactTable ->
                                                "there must be at least one fact table"

                                            InputMustContainAtLeastOneDimensionTable ->
                                                "there must be at least one dimension table"

                            Nothing ->
                                " "
                        )
                    )
                ]
    in
    row
        [ width fill
        , height (px 40)
        , Font.size 30
        , Border.width 1
        , Border.color Palette.darkishGrey
        , Background.color Palette.white
        , spacing 6
        ]
        [ viewViewBoxControls
        , viewGraphControlPanel
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
            , viewControlPanel model
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
    el [ width fill, height fill, Border.width 1, Border.color Palette.darkishGrey ]
        (paragraph []
            [ E.text <| "events: " ++ mouseEventStr
            , E.text <| "drag state: " ++ dragStateStr
            , E.text <| "veiwPort: " ++ viewPortStr
            , E.text <| "dim model: " ++ selectedModelStr
            ]
        )


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
                            case Dict.get (refToString ref) selectedDimModel.tableInfos of
                                Just info ->
                                    case info.isIncluded of
                                        True ->
                                            Palette.green_keylime

                                        False ->
                                            Palette.white

                                Nothing ->
                                    Palette.white

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
            text err



-- end region view
