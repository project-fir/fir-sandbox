module Pages.Stories.EntityRelationshipDiagram exposing (Model, Msg, page)

import Dict exposing (Dict)
import DimensionalModel exposing (CardRenderInfo, ColumnGraph, DimModelDuckDbSourceInfo, DimensionalModel, EdgeLabel(..), KimballAssignment(..), PositionPx, addEdges, addNodes, columnDescFromNodeId, edgesOfType)
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



-- INIT


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
            [ Persisted_ { name = "id", parentRef = DuckDbTable dimRef, dataType = "String" }
            , Persisted_ { name = "attr_1", parentRef = DuckDbTable dimRef, dataType = "String" }
            , Persisted_ { name = "attr_2", parentRef = DuckDbTable dimRef, dataType = "String" }
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
                [ ( lhs, rhs, Joinable )
                , ( rhs, lhs, Joinable )
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
                            { pos = { x = 40.0, y = 175.0 }
                            , ref = dimRef
                            , isDrawerOpen = False
                            }
                        , assignment = Dimension (DuckDbTable dimRef) dimCols
                        , isIncluded = True
                        }
                      )
                    , ( refToString factRef
                      , { renderInfo =
                            { pos = { x = 430.0, y = 325.0 }
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
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserToggledDummyDropdown ->
            ( { model
                | msgHistory = msg :: model.msgHistory
                , isDummyDrawerOpen = not model.isDummyDrawerOpen
              }
            , Effect.none
            )

        UserToggledErdCardDropdown ref ->
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
                UserClickedErdCardColumn ->
                    "UserClickedErdCardColumn"

                UserHoveredOverErdCardColumn ->
                    "UserHoveredOverErdCardColumn"

                UserToggledErdCardDropdown ref ->
                    "UserToggledErdCardDropdown " ++ refToString ref

                UserSelectedErdCardDropdownOption ->
                    "UserSelectedErdCardDropdownOption"

                MouseEnteredErdCard ->
                    "UserHoveredOverErdCard"

                UserClickedButton ->
                    "UserClickedButton"

                MouseLeftErdCard ->
                    "MouseLeftErdCard"

                UserHoveredOverOption ->
                    "UserHoveredOverOption"

                UserToggledDummyDropdown ->
                    "UserToggledDummyDropdown"

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


viewCanvas : Model -> Element Msg
viewCanvas model =
    let
        width_ =
            750

        height_ =
            575
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
                (viewSvgErdCards model ++ viewLines model)


erdCardWidth =
    250


erdCardHeight =
    400


computeLineCoords : ColumnGraph -> Dict DuckDbRefString DimModelDuckDbSourceInfo -> List (Edge EdgeLabel) -> List ( PositionPx, PositionPx )
computeLineCoords graph tableInfos edges =
    let
        coordsFor : Edge EdgeLabel -> Maybe ( PositionPx, PositionPx )
        coordsFor edge =
            let
                compute : DimModelDuckDbSourceInfo -> DimModelDuckDbSourceInfo -> ( PositionPx, PositionPx )
                compute fromInfo toInfo =
                    ( { x = fromInfo.renderInfo.pos.x, y = fromInfo.renderInfo.pos.y }
                    , { x = toInfo.renderInfo.pos.x, y = toInfo.renderInfo.pos.y }
                    )

                tableInfosFromNodeId : NodeId -> Maybe DimModelDuckDbSourceInfo
                tableInfosFromNodeId nodeId =
                    case columnDescFromNodeId graph nodeId of
                        Just colDesc ->
                            case colDesc of
                                Persisted_ colDesc_ ->
                                    Dict.get (ref_ToString colDesc_.parentRef) tableInfos

                                -- TODO: Computed support
                                Computed_ colDesc_ ->
                                    Nothing

                        Nothing ->
                            Nothing
            in
            case edge.label of
                CommonRef ->
                    Nothing

                Joinable ->
                    case tableInfosFromNodeId edge.from of
                        Nothing ->
                            Nothing

                        Just fromInfos ->
                            case tableInfosFromNodeId edge.to of
                                Nothing ->
                                    Nothing

                                Just toInfos ->
                                    Just (compute fromInfos toInfos)

        coords : List (Maybe ( PositionPx, PositionPx ))
        coords =
            List.map (\lbl -> coordsFor lbl) edges
    in
    List.filterMap identity coords


viewLines : Model -> List (Svg Msg)
viewLines model =
    let
        joinables : List (Edge EdgeLabel)
        joinables =
            edgesOfType model.dimModel.graph Joinable

        coords : List ( PositionPx, PositionPx )
        coords =
            computeLineCoords model.dimModel.graph model.dimModel.tableInfos joinables

        lineFromCoords : ( PositionPx, PositionPx ) -> Svg Msg
        lineFromCoords ( p1, p2 ) =
            S.line
                [ SA.x1 (ST.px p1.x)
                , SA.y1 (ST.px p1.y)
                , SA.x2 (ST.px p2.x)
                , SA.y2 (ST.px p2.y)
                , SA.stroke (ST.Paint (toAvhColor model.theme.black))
                ]
                []
    in
    List.map (\coord -> lineFromCoords coord) coords


viewSvgErdCards : Model -> List (Svg Msg)
viewSvgErdCards model =
    -- For each included table, render an Svg foreignObject, which is an elm-ui layout rendering a diagram card.
    let
        foreignObjectHelper : DimModelDuckDbSourceInfo -> Svg Msg
        foreignObjectHelper duckDbSourceInfo =
            SC.foreignObject
                [ SA.x (ST.px duckDbSourceInfo.renderInfo.pos.x)
                , SA.y (ST.px duckDbSourceInfo.renderInfo.pos.y)
                , SA.width (ST.px erdCardWidth)
                , SA.height (ST.px erdCardHeight)
                ]
                [ E.layoutWith { options = [ noStaticStyleSheet ] }
                    []
                    (viewEntityRelationshipCard model duckDbSourceInfo.assignment)
                ]
    in
    List.map (\info -> foreignObjectHelper info) (Dict.values model.dimModel.tableInfos)


viewEntityRelationshipCard : Model -> KimballAssignment DuckDbRef_ (List DuckDbColumnDescription) -> Element Msg
viewEntityRelationshipCard model kimballAssignment =
    let
        colDescs : List DuckDbColumnDescription
        colDescs =
            case kimballAssignment of
                Unassigned _ columns ->
                    columns

                Fact _ columns ->
                    columns

                Dimension _ columns ->
                    columns

        ( duckDbRef_, assignmentType, computedBackgroundColor ) =
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

        viewCardTitleBar : Element Msg
        viewCardTitleBar =
            let
                titleBarHeightPx =
                    40

                isDrawOpen : Bool
                isDrawOpen =
                    case Dict.get (refToString duckDbRef_) model.dimModel.tableInfos of
                        Just info ->
                            info.renderInfo.isDrawerOpen

                        Nothing ->
                            False

                dropDownProps : DropDownProps Msg
                dropDownProps =
                    { isOpen = isDrawOpen
                    , widthPx = 25
                    , heightPx = titleBarHeightPx - 1
                    , onDrawerClick = UserToggledErdCardDropdown duckDbRef_
                    , onMenuMouseEnter = MouseEnteredErdCard
                    , onMenuMouseLeave = MouseLeftErdCard
                    , isMenuHovered = False
                    , menuBarText = ""
                    , options =
                        [ { displayText = "Apples"
                          , optionId = 1
                          , onClick = UserSelectedErdCardDropdownOption
                          , onHover = UserHoveredOverOption
                          }
                        , { displayText = "Bananas"
                          , optionId = 2
                          , onClick = UserSelectedErdCardDropdownOption
                          , onHover = UserHoveredOverOption
                          }
                        , { displayText = "Pears"
                          , optionId = 2
                          , onClick = UserSelectedErdCardDropdownOption
                          , onHover = UserHoveredOverOption
                          }
                        ]
                    , hoveredOnOption = Nothing
                    }
            in
            el [ width fill, height fill, paddingXY 2 0 ]
                (row
                    [ width fill
                    , paddingXY 3 0
                    , height (px titleBarHeightPx)
                    , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
                    , Border.color model.theme.secondary
                    ]
                    [ E.text (refToString duckDbRef_)
                    , el [ alignRight ] <| dropdownMenu model dropDownProps
                    ]
                )

        viewCardBody : Element Msg
        viewCardBody =
            let
                viewNub : Attribute Msg -> Element Msg
                viewNub alignment =
                    el
                        (alignment
                            :: [ Border.width 1
                               , Border.color model.theme.secondary
                               , Background.color model.theme.background
                               , padding 3
                               ]
                        )
                        E.none

                colDisplayText : DuckDbColumnDescription -> String
                colDisplayText desc =
                    case desc of
                        Persisted_ desc_ ->
                            desc_.name

                        Computed_ desc_ ->
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

        cardWidthPx =
            250

        cardHeightPx =
            -- title bar + body (depends on length) + footer / padding
            41 + (25 * List.length colDescs) + 5
    in
    column
        [ width (px cardWidthPx)
        , height (px cardHeightPx)
        , Background.color computedBackgroundColor
        , Border.width 1
        , Border.color model.theme.secondary
        , Border.rounded 5
        ]
        [ viewCardTitleBar
        , viewCardBody
        ]
