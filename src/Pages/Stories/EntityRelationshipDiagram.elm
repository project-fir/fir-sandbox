module Pages.Stories.EntityRelationshipDiagram exposing (ErdSvgNodeProps, Model, Msg, page, viewErdSvgNodes)

import Dict exposing (Dict)
import DimensionalModel exposing (CardRenderInfo, ColumnGraph, ColumnGraphEdge, DimModelDuckDbSourceInfo, DimensionalModel, DimensionalModelRef, EdgeFamily(..), EdgeLabel(..), KimballAssignment(..), LineSegment, PositionPx, addEdges, addNodes, columnDescFromNodeId, edgesOfFamily, unpackKimballAssignment)
import DuckDb exposing (DuckDbColumnDescription(..), DuckDbRef, DuckDbRefString, DuckDbRef_(..), refToString, ref_ToString)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Stories.EntityRelationshipDiagram exposing (Params)
import Graph exposing (Edge, NodeId)
import Html.Events.Extra.Mouse exposing (Event)
import List.Extra
import Page
import Request
import Shared
import TypedSvg as S
import TypedSvg.Attributes as SA
import TypedSvg.Core as SC exposing (Svg)
import TypedSvg.Types as ST
import Ui exposing (ColorTheme, DropDownOption, DropDownOptionId, DropDownProps, button, dropdownMenu, toAvhColor)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    { theme : ColorTheme
    , dimModel : DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    let
        dimRef : DuckDbRef
        dimRef =
            { schemaName = "story", tableName = "some_dim" }

        dimCols : List DuckDbColumnDescription
        dimCols =
            [ Persisted_ { name = "attr_1", parentRef = DuckDbTable dimRef, dataType = "String" }
            , Persisted_ { name = "attr_2", parentRef = DuckDbTable dimRef, dataType = "String" }
            , Persisted_ { name = "id", parentRef = DuckDbTable dimRef, dataType = "String" }
            ]

        factRef : DuckDbRef
        factRef =
            { schemaName = "story", tableName = "some_fact" }

        factCols : List DuckDbColumnDescription
        factCols =
            [ Persisted_ { name = "fact_id", parentRef = DuckDbTable factRef, dataType = "String" }
            , Persisted_ { name = "dim_key", parentRef = DuckDbTable factRef, dataType = "String" }
            , Persisted_ { name = "measure_1", parentRef = DuckDbTable factRef, dataType = "Float" }
            ]

        graphStep1 : ColumnGraph
        graphStep1 =
            addNodes Graph.empty (factCols ++ dimCols)

        graphStep2 : ColumnGraph
        graphStep2 =
            let
                lhs =
                    Persisted_ { name = "dim_key", parentRef = DuckDbTable factRef, dataType = "String" }

                rhs =
                    Persisted_ { name = "id", parentRef = DuckDbTable dimRef, dataType = "String" }
            in
            addEdges graphStep1
                [ ( lhs, rhs, Joinable lhs rhs )
                , ( rhs, lhs, Joinable rhs lhs )
                ]
    in
    ( { theme = shared.selectedTheme
      , dimModel =
            { graph = graphStep2
            , ref = "story_dim_model"
            , tableInfos =
                Dict.fromList
                    [ ( refToString dimRef
                      , { renderInfo =
                            { pos = { x = 450.0, y = 170.0 }
                            , ref = dimRef
                            , isDrawerOpen = False
                            }
                        , assignment = Dimension (DuckDbTable dimRef) dimCols
                        , isIncluded = True
                        }
                      )
                    , ( refToString factRef
                      , { renderInfo =
                            { pos = { x = 14.0, y = 50.0 }

                            --pos = { x = 40.0, y = 175.0 }
                            , ref = factRef
                            , isDrawerOpen = False
                            }
                        , assignment = Fact (DuckDbTable factRef) factCols
                        , isIncluded = True
                        }
                      )
                    ]
            }
      , msgHistory = []
      , isDummyDrawerOpen = False
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = MouseEnteredErdCard DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow DuckDbRef DuckDbColumnDescription
    | ClickedErdCardColumnRow DuckDbRef DuckDbColumnDescription
    | ToggledErdCardDropdown DuckDbRef
    | MouseEnteredErdCardDropdown DuckDbRef
    | MouseLeftErdCardDropdown DuckDbRef
    | ClickedErdCardDropdownOption DimensionalModelRef DuckDbRef (KimballAssignment DuckDbRef_ (List DuckDbColumnDescription))
    | BeginErdCardDrag DuckDb.DuckDbRef
    | ContinueErdCardDrag Event
    | ErdCardDragStopped Event
    | ErdNoop
    | ErdNoop_ DuckDbRef


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    -- NB: This is a visual component test, the goal is to ensure visual integrity and Msg responsiveness
    --     Therefore, we only "actually" process Msgs that are strictly necessary for those checks.
    --     For all other cases, we publish the Msg history to the debug panel, so the tester can verify
    --     Msgs are being sent to the Elm runtime.
    case msg of
        ToggledErdCardDropdown ref ->
            let
                newSourceInfo =
                    case Dict.get (refToString ref) model.dimModel.tableInfos of
                        Nothing ->
                            Nothing

                        Just info ->
                            let
                                renderInfo =
                                    info.renderInfo

                                newRenderInfo =
                                    { renderInfo | isDrawerOpen = not renderInfo.isDrawerOpen }
                            in
                            Just { info | renderInfo = newRenderInfo }

                newTableInfos =
                    case newSourceInfo of
                        Just tableInfos_ ->
                            Dict.insert (refToString ref) tableInfos_ model.dimModel.tableInfos

                        Nothing ->
                            model.dimModel.tableInfos

                dimModel =
                    model.dimModel

                newDimModel =
                    { dimModel | tableInfos = newTableInfos }
            in
            ( { model
                | msgHistory = msg :: model.msgHistory
                , dimModel = newDimModel
              }
            , Effect.none
            )

        --( model, Effect.none )
        _ ->
            ( { model | msgHistory = msg :: model.msgHistory }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Stories - ERD"
    , body = el [ width fill, height fill, Background.color model.theme.deadspace, padding 5 ] <| viewElements model
    }


viewDebugInfo : Model -> Element Msg
viewDebugInfo model =
    let
        msg2str : Msg -> String
        msg2str msg =
            case msg of
                _ ->
                    "Some event happened!"

        viewMsg : Msg -> Element Msg
        viewMsg msg =
            paragraph [ padding 5 ] [ E.text (msg2str msg) ]
    in
    textColumn [ paddingXY 0 5, clipY, scrollbarY, height fill ] <|
        [ paragraph [ Font.bold, Font.size 24 ] [ E.text "Debug info:" ]
        , paragraph [] [ E.text "Msgs:" ]
        ]
            ++ List.map (\m -> viewMsg m) model.msgHistory


viewElements : Model -> Element Msg
viewElements model =
    row [ width fill, height fill ]
        [ column
            [ height fill
            , width (px 800)
            , padding 5
            , Background.color model.theme.background
            , centerX
            ]
            [ viewCanvas model
            ]
        , column
            [ height fill
            , width (px 250)
            , padding 5
            , Background.color model.theme.background
            , centerX
            ]
            [ viewDebugInfo model
            ]
        ]


assembleErdCardPropsForSingleSource : DimModelDuckDbSourceInfo -> ( DuckDbRefString, ErdSvgNodeProps Msg )
assembleErdCardPropsForSingleSource info =
    let
        ref : DuckDbRef
        ref =
            case info.assignment of
                Unassigned ref_ _ ->
                    case ref_ of
                        DuckDbTable duckDbRef ->
                            duckDbRef

                Fact ref_ _ ->
                    case ref_ of
                        DuckDbTable duckDbRef ->
                            duckDbRef

                Dimension ref_ _ ->
                    case ref_ of
                        DuckDbTable duckDbRef ->
                            duckDbRef

        cardDropDownProps : DropDownProps Msg DuckDbRef
        cardDropDownProps =
            { isOpen = False
            , id = ref
            , widthPx = 250
            , heightPx = 250
            , onDrawerClick = ToggledErdCardDropdown
            , onMenuMouseEnter = MouseEnteredErdCardDropdown
            , onMenuMouseLeave = MouseLeftErdCardDropdown
            , isMenuHovered = False
            , menuBarText = "TEST"
            , options = []
            , hoveredOnOption = Nothing
            }
    in
    ( refToString ref
    , { id = ref
      , onMouseEnteredErdCard = MouseEnteredErdCard
      , onMouseLeftErdCard = MouseLeftErdCard
      , onMouseEnteredErdCardColumnRow = MouseEnteredErdCardColumnRow
      , onClickedErdCardColumnRow = ClickedErdCardColumnRow
      , onBeginErdCardDrag = BeginErdCardDrag
      , onContinueErdCardDrag = ContinueErdCardDrag
      , onErdCardDragStopped = ErdCardDragStopped
      , erdCardDropdownMenuProps = cardDropDownProps
      }
    )


viewCanvas : Model -> Element Msg
viewCanvas model =
    let
        width_ : number
        width_ =
            750

        height_ : number
        height_ =
            575

        erdCardPropsSet : DimensionalModel -> Dict DuckDbRefString (ErdSvgNodeProps Msg)
        erdCardPropsSet dimModel =
            Dict.fromList <| List.map (\tblInfo -> assembleErdCardPropsForSingleSource tblInfo) (Dict.values dimModel.tableInfos)
    in
    el
        [ Border.width 1

        --, Border.color model.theme.black
        , Border.rounded 5
        , Background.color model.theme.background
        , centerX
        , centerY
        ]
    <|
        E.html <|
            S.svg
                [ SA.width (ST.px width_)
                , SA.height (ST.px height_)
                , SA.viewBox 0 0 width_ height_
                ]
                (viewErdSvgNodes model (erdCardPropsSet model.dimModel) model.dimModel)


offsetHelper : Maybe DuckDbColumnDescription -> List DuckDbColumnDescription -> Float
offsetHelper colDesc colDescs =
    -- Default to zero if issue. Line will render but in the wrong place
    case colDesc of
        Just colDesc_ ->
            case List.Extra.elemIndex colDesc_ colDescs of
                Just i ->
                    toFloat i + 0.5

                Nothing ->
                    0

        Nothing ->
            0


computeLineSegmentsFromSingleEdge : ColumnGraph -> Dict DuckDbRefString DimModelDuckDbSourceInfo -> Edge ColumnGraphEdge -> Maybe LineSegment
computeLineSegmentsFromSingleEdge graph tableInfos edge =
    let
        compute : DimModelDuckDbSourceInfo -> DimModelDuckDbSourceInfo -> LineSegment
        compute fromInfo toInfo =
            let
                x1 : Float
                x1 =
                    fromInfo.renderInfo.pos.x

                x2 : Float
                x2 =
                    toInfo.renderInfo.pos.x

                y1 : Float
                y1 =
                    fromInfo.renderInfo.pos.y

                y2 : Float
                y2 =
                    toInfo.renderInfo.pos.y

                x1_ : Float
                x1_ =
                    if x2 > x1 then
                        -- Move x1 to rhs of card
                        x1 + erdCardWidth

                    else
                        x1

                x2_ : Float
                x2_ =
                    if x1 + erdCardWidth < x2 then
                        x2

                    else
                        x2 + erdCardWidth

                ( _, fromColDescs ) =
                    unpackKimballAssignment fromInfo.assignment

                ( _, toColDescs ) =
                    unpackKimballAssignment toInfo.assignment

                fromColDesc : Maybe DuckDbColumnDescription
                fromColDesc =
                    case edge.label of
                        CommonRef _ _ ->
                            Nothing

                        Joinable lhs _ ->
                            Just lhs

                toColDesc : Maybe DuckDbColumnDescription
                toColDesc =
                    case edge.label of
                        CommonRef _ _ ->
                            Nothing

                        Joinable _ rhs ->
                            Just rhs

                y1Offset : Float
                y1Offset =
                    toFloat titleBarHeightPx + (columnBarHeightPx * offsetHelper fromColDesc fromColDescs)

                y2Offset : Float
                y2Offset =
                    toFloat titleBarHeightPx + (columnBarHeightPx * offsetHelper toColDesc toColDescs)
            in
            ( { x = x1_, y = y1 + y1Offset }
            , { x = x2_, y = y2 + y2Offset }
            )

        tableInfosFromNodeId : NodeId -> Maybe DimModelDuckDbSourceInfo
        tableInfosFromNodeId nodeId =
            case columnDescFromNodeId graph nodeId of
                Just colDesc ->
                    case colDesc of
                        Persisted_ colDesc_ ->
                            Dict.get (ref_ToString colDesc_.parentRef) tableInfos

                Nothing ->
                    Nothing
    in
    case edge.label of
        CommonRef _ _ ->
            Nothing

        Joinable _ _ ->
            case tableInfosFromNodeId edge.from of
                Nothing ->
                    Nothing

                Just fromInfos ->
                    case tableInfosFromNodeId edge.to of
                        Nothing ->
                            Nothing

                        Just toInfos ->
                            Just (compute fromInfos toInfos)


computeLineSegmentsFromEdges : ColumnGraph -> Dict DuckDbRefString DimModelDuckDbSourceInfo -> List (Edge ColumnGraphEdge) -> List LineSegment
computeLineSegmentsFromEdges graph tableInfos edges =
    -- First, iterate through all edges, generating a List of Maybe LineSegments. Then, filter out Nothings from that
    -- list, to return List (LineSegment)
    let
        helper : List (Maybe LineSegment)
        helper =
            List.map (\lbl -> computeLineSegmentsFromSingleEdge graph tableInfos lbl) edges
    in
    List.filterMap identity helper


viewLines : { r | theme : ColorTheme } -> DimensionalModel -> List (Svg msg)
viewLines r dimModel =
    let
        joinables : List (Edge ColumnGraphEdge)
        joinables =
            edgesOfFamily dimModel.graph Joinable_

        coords : List ( PositionPx, PositionPx )
        coords =
            computeLineSegmentsFromEdges dimModel.graph dimModel.tableInfos joinables

        lineFromCoords : LineSegment -> Svg msg
        lineFromCoords ( p1, p2 ) =
            S.line
                [ SA.x1 (ST.px p1.x)
                , SA.y1 (ST.px p1.y)
                , SA.x2 (ST.px p2.x)
                , SA.y2 (ST.px p2.y)
                , SA.stroke (ST.Paint (toAvhColor r.theme.black))
                ]
                []
    in
    List.map (\coord -> lineFromCoords coord) coords



-- begin region: ERD Card constants
-- NB: These constants are shared among several functions in this story, but are not intended to be exposed
--     if you think you need to expose, I recommend first trying to implement the functionality in this module


erdCardWidth =
    250


erdCardHeightPx : List DuckDbColumnDescription -> Float
erdCardHeightPx colDescs =
    -- title bar + body (depends on length) + footer / padding
    toFloat <| (titleBarHeightPx + 1) + (columnBarHeightPx * List.length colDescs) + 5


titleBarHeightPx =
    40


columnBarHeightPx =
    25



-- end region: ERD Card constants
-- begin region: exposed UI components


type alias ErdSvgNodeProps msg =
    { id : DuckDbRef
    , onMouseEnteredErdCard : DuckDbRef -> msg
    , onMouseLeftErdCard : msg
    , onMouseEnteredErdCardColumnRow : DuckDbRef -> DuckDbColumnDescription -> msg
    , onClickedErdCardColumnRow : DuckDbRef -> DuckDbColumnDescription -> msg
    , onBeginErdCardDrag : DuckDbRef -> msg
    , onContinueErdCardDrag : Event -> msg
    , onErdCardDragStopped : Event -> msg
    , erdCardDropdownMenuProps : DropDownProps msg DuckDbRef
    }


viewErdSvgNodes : { r | theme : ColorTheme } -> Dict DuckDbRefString (ErdSvgNodeProps msg) -> DimensionalModel -> List (Svg msg)
viewErdSvgNodes r propsDict dimModel =
    viewSvgErdCards r propsDict dimModel ++ viewLines r dimModel


viewSvgErdCards : { r | theme : ColorTheme } -> Dict DuckDbRefString (ErdSvgNodeProps msg) -> DimensionalModel -> List (Svg msg)
viewSvgErdCards r propsDict dimModel =
    -- For each included table, render an Svg foreignObject, which is an elm-ui layout rendering a diagram card.
    let
        unpackColDescs : DimModelDuckDbSourceInfo -> List DuckDbColumnDescription
        unpackColDescs sourceInfo =
            case sourceInfo.assignment of
                Unassigned _ columns ->
                    columns

                Fact _ columns ->
                    columns

                Dimension _ columns ->
                    columns

        erdCardProps : DuckDbRefString -> Maybe (ErdSvgNodeProps msg)
        erdCardProps refString =
            Dict.get refString propsDict

        foreignObjectHelper : DimModelDuckDbSourceInfo -> DuckDbRefString -> Svg msg
        foreignObjectHelper duckDbSourceInfo refString =
            SC.foreignObject
                [ SA.x (ST.px duckDbSourceInfo.renderInfo.pos.x)
                , SA.y (ST.px duckDbSourceInfo.renderInfo.pos.y)
                , SA.width (ST.px erdCardWidth)
                , SA.height (ST.px (erdCardHeightPx (unpackColDescs duckDbSourceInfo)))
                ]
                [ E.layoutWith { options = [ noStaticStyleSheet ] }
                    []
                    (case erdCardProps refString of
                        Nothing ->
                            E.none

                        Just cardProps ->
                            viewEntityRelationshipCard r dimModel duckDbSourceInfo.assignment cardProps
                    )
                ]
    in
    List.map (\( refString, info ) -> foreignObjectHelper info refString) (Dict.toList dimModel.tableInfos)


viewEntityRelationshipCard : { r | theme : ColorTheme } -> DimensionalModel -> KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) -> ErdSvgNodeProps msg -> Element msg
viewEntityRelationshipCard r dimModel kimballAssignment erdCardProps =
    let
        ( duckDbRef_, assignmentType, computedBackgroundColor ) =
            case kimballAssignment of
                Unassigned ref _ ->
                    case ref of
                        DuckDbTable duckDbRef ->
                            ( duckDbRef, "Unassigned", r.theme.debugWarn )

                Fact ref _ ->
                    case ref of
                        DuckDbTable duckDbRef ->
                            ( duckDbRef, "Fact", r.theme.primary1 )

                Dimension ref _ ->
                    case ref of
                        DuckDbTable duckDbRef ->
                            ( duckDbRef, "Dimension", r.theme.primary2 )

        colDescs : List DuckDbColumnDescription
        colDescs =
            case kimballAssignment of
                Unassigned _ columns ->
                    columns

                Fact _ columns ->
                    columns

                Dimension _ columns ->
                    columns

        viewCardTitleBar : Element msg
        viewCardTitleBar =
            let
                isDrawOpen : Bool
                isDrawOpen =
                    case Dict.get (refToString duckDbRef_) dimModel.tableInfos of
                        Just info ->
                            info.renderInfo.isDrawerOpen

                        Nothing ->
                            False
            in
            el [ width fill, height fill, paddingXY 2 0 ]
                (row
                    [ width fill
                    , paddingXY 3 0
                    , height (px titleBarHeightPx)
                    , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
                    , Border.color r.theme.secondary
                    ]
                    [ E.text (refToString duckDbRef_)
                    , el [ alignRight ] <| dropdownMenu r erdCardProps.erdCardDropdownMenuProps
                    ]
                )

        viewCardBody : Element msg
        viewCardBody =
            let
                viewNub : Attribute msg -> Element msg
                viewNub alignment =
                    el
                        (alignment
                            :: [ Border.width 1
                               , Border.color r.theme.secondary
                               , Background.color r.theme.background
                               , padding 3
                               ]
                        )
                        E.none

                colDisplayText : DuckDbColumnDescription -> String
                colDisplayText desc =
                    case desc of
                        Persisted_ desc_ ->
                            desc_.name
            in
            column [ width fill, height fill ]
                (List.map
                    (\col ->
                        row [ width fill, paddingXY 5 3 ]
                            [ viewNub alignLeft
                            , el [ centerX ] (E.text (colDisplayText col))
                            , viewNub alignRight
                            ]
                    )
                    colDescs
                )
    in
    column
        [ width (px erdCardWidth)
        , height (px <| round (erdCardHeightPx colDescs))
        , Background.color computedBackgroundColor
        , Border.width 1
        , Border.color r.theme.secondary
        , Border.rounded 5
        ]
        [ viewCardTitleBar
        , viewCardBody
        ]



-- end region: exposed UI components
