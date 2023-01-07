module Pages.Stories.EntityRelationshipDiagram exposing (ErdSvgNodeProps, Model, Msg, page, viewErdSvgNodes)

import Dict exposing (Dict)
import DimensionalModel exposing (CardRenderInfo, ColumnGraph, ColumnGraphEdge, DimModelDuckDbSourceInfo, DimensionalModel, DimensionalModelRef, EdgeFamily(..), EdgeLabel(..), KimballAssignment(..), LineSegment, Position, addEdges, addNodes, columnDescFromNodeId, edgesOfFamily, unpackKimballAssignment)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import FirApi exposing (DuckDbColumnDescription, DuckDbRef, DuckDbRefString, DuckDbRef_(..), refToString, ref_ToString)
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
import Ui exposing (ColorTheme, DropDownOption, DropDownProps, button, dropdownMenu, toAvhColor)
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
    , dimModel1 : DimensionalModel
    , dimModel2 : DimensionalModel
    , dimModel3 : DimensionalModel
    , dimModel4 : DimensionalModel
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
            [ { name = "attr_1", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "attr_2", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "attr_3", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "attr_4", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "attr_5", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "attr_6", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "id", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "attr_7", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "attr_8", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "attr_9", parentRef = DuckDbTable dimRef, dataType = "String" }
            , { name = "attr_10", parentRef = DuckDbTable dimRef, dataType = "String" }
            ]

        factRef : DuckDbRef
        factRef =
            { schemaName = "story", tableName = "some_fact" }

        factCols : List DuckDbColumnDescription
        factCols =
            [ { name = "fact_id", parentRef = DuckDbTable factRef, dataType = "String" }
            , { name = "dim_key", parentRef = DuckDbTable factRef, dataType = "String" }
            , { name = "measure_1", parentRef = DuckDbTable factRef, dataType = "Float" }
            ]

        graphStep1 : ColumnGraph
        graphStep1 =
            addNodes Graph.empty (factCols ++ dimCols)

        graphStep2 : ColumnGraph
        graphStep2 =
            let
                lhs =
                    { name = "dim_key", parentRef = DuckDbTable factRef, dataType = "String" }

                rhs =
                    { name = "id", parentRef = DuckDbTable dimRef, dataType = "String" }
            in
            addEdges graphStep1
                [ ( lhs, rhs, Joinable lhs rhs )
                , ( rhs, lhs, Joinable rhs lhs )
                ]

        assembleDimModel : Position -> Position -> DimensionalModel
        assembleDimModel p1 p2 =
            { graph = graphStep2
            , ref = "story_dim_model"
            , tableInfos =
                Dict.fromList
                    [ ( refToString dimRef
                      , { renderInfo =
                            { pos = p1
                            , ref = dimRef
                            , isDrawerOpen = False
                            }
                        , assignment = Dimension (DuckDbTable dimRef) dimCols
                        , isIncluded = True
                        }
                      )
                    , ( refToString factRef
                      , { renderInfo =
                            { pos = p2
                            , ref = factRef
                            , isDrawerOpen = False
                            }
                        , assignment = Fact (DuckDbTable factRef) factCols
                        , isIncluded = True
                        }
                      )
                    ]
            }
    in
    ( { theme = shared.selectedTheme
      , dimModel1 = assembleDimModel { x = 450, y = 25 } { x = 100, y = 400 }
      , dimModel2 = assembleDimModel { x = 450, y = 25 } { x = 250, y = 400 }
      , dimModel3 = assembleDimModel { x = 150, y = 25 } { x = 250, y = 400 }
      , dimModel4 = assembleDimModel { x = 150, y = 25 } { x = 450, y = 400 }
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
    | MouseLeftErdCardDropdown
    | ClickedErdCardDropdownOption DimensionalModelRef DuckDbRef (KimballAssignment DuckDbRef_ (List DuckDbColumnDescription))
    | BeginErdCardDrag FirApi.DuckDbRef
    | ContinueErdCardDrag Event
    | ErdCardDragStopped Event


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    -- NB: This is a visual component test, the goal is to ensure visual integrity and Msg responsiveness
    --     Therefore, we only "actually" process Msgs that are strictly necessary for those checks.
    --     For all other cases, we publish the Msg history to the debug panel, so the tester can verify
    --     Msgs are being sent to the Elm runtime.
    case msg of
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
                MouseEnteredErdCard duckDbRef ->
                    "MouseEnteredErdCard " ++ refToString duckDbRef

                MouseLeftErdCard ->
                    "MouseLeftErdCard"

                MouseEnteredErdCardColumnRow duckDbRef duckDbColumnDescription ->
                    "MouseEnteredErdCardColumnRow "
                        ++ refToString duckDbRef
                        ++ ":"
                        ++ duckDbColumnDescription.name

                ClickedErdCardColumnRow duckDbRef duckDbColumnDescription ->
                    "ClickedErdCardColumnRow "
                        ++ refToString duckDbRef
                        ++ ":"
                        ++ duckDbColumnDescription.name

                ToggledErdCardDropdown duckDbRef ->
                    "ToggledErdCardDropdown " ++ refToString duckDbRef

                MouseEnteredErdCardDropdown duckDbRef ->
                    "MouseEnteredErdCardDropdown " ++ refToString duckDbRef

                MouseLeftErdCardDropdown ->
                    "MouseLeftErdCardDropdown"

                ClickedErdCardDropdownOption dimensionalModelRef duckDbRef kimballAssignment ->
                    "ClickedErdCardDropdownOption "
                        ++ dimensionalModelRef
                        ++ " - "
                        ++ refToString duckDbRef
                        ++ ": "
                        ++ (case kimballAssignment of
                                Unassigned ref columns ->
                                    "unassigned"

                                Fact ref columns ->
                                    "fact"

                                Dimension ref columns ->
                                    "dimension"
                           )

                BeginErdCardDrag duckDbRef ->
                    "BeginErdCardDrag " ++ refToString duckDbRef

                ContinueErdCardDrag event ->
                    "ContinueErdCardDrag"

                ErdCardDragStopped event ->
                    "ErdCardDragStopped"

        viewMsg : Msg -> Element Msg
        viewMsg msg =
            paragraph [ padding 5 ] [ E.text (msg2str msg) ]
    in
    textColumn
        [ paddingXY 0 5
        , clipY
        , scrollbarY
        , height fill
        , Border.width 1
        , width fill
        , clipX
        , Border.color model.theme.black
        ]
    <|
        [ paragraph [ Font.bold, Font.size 24 ] [ E.text "Debug info:" ]
        , paragraph [] [ E.text "Msgs:" ]
        ]
            ++ List.map (\m -> viewMsg m) model.msgHistory


viewElements : Model -> Element Msg
viewElements model =
    row [ width fill, height fill ]
        [ column
            [ height fill
            , width fill
            , padding 5
            , Background.color model.theme.background
            , centerX
            ]
            [ row [ width fill, height fill ]
                [ E.text "Case 1:"
                , viewCanvas model model.dimModel1
                , E.text "Case 2:"
                , viewCanvas model model.dimModel2
                ]
            , row [ width fill, height fill ]
                [ E.text "Case 3:"
                , viewCanvas model model.dimModel3
                , E.text "Case 4:"
                , viewCanvas model model.dimModel4
                ]
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

        cardDropDownProps : DropDownProps Msg DuckDbRef Int
        cardDropDownProps =
            { isOpen = False
            , id = ref
            , widthPx = 45
            , heightPx = 25
            , onDrawerClick = ToggledErdCardDropdown
            , onMenuMouseEnter = MouseEnteredErdCardDropdown
            , onMenuMouseLeave = MouseLeftErdCardDropdown
            , isMenuHovered = False
            , menuBarText = "TEST"
            , options = Dict.empty
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


viewCanvas : { r | theme : ColorTheme } -> DimensionalModel -> Element Msg
viewCanvas r dimModel =
    let
        width_ : number
        width_ =
            600

        height_ : number
        height_ =
            400

        erdCardPropsDict : DimensionalModel -> Dict DuckDbRefString (ErdSvgNodeProps Msg)
        erdCardPropsDict dimModel_ =
            Dict.fromList <| List.map (\tblInfo -> assembleErdCardPropsForSingleSource tblInfo) (Dict.values dimModel_.tableInfos)
    in
    el
        [ Border.width 1
        , Border.color r.theme.black
        , Border.rounded 5
        , Background.color r.theme.background
        , centerX
        , centerY
        ]
    <|
        E.html <|
            S.svg
                [ SA.width (ST.px width_)
                , SA.height (ST.px height_)
                , SA.viewBox 0 0 (1.5 * width_) (1.5 * height_)
                ]
                (viewErdSvgNodes r (erdCardPropsDict dimModel) dimModel)


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
            -- NB: This logic is a bit complex
            --     Please only change it if you are using this story in an interactive dev session!
            let
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

                ( ( x1, y1 ), ( x2, y2 ) ) =
                    if fromInfo.renderInfo.pos.x < toInfo.renderInfo.pos.x then
                        ( ( fromInfo.renderInfo.pos.x, fromInfo.renderInfo.pos.y )
                        , ( toInfo.renderInfo.pos.x, toInfo.renderInfo.pos.y )
                        )

                    else
                        ( ( toInfo.renderInfo.pos.x, toInfo.renderInfo.pos.y )
                        , ( fromInfo.renderInfo.pos.x, fromInfo.renderInfo.pos.y )
                        )

                y1Offset : Float
                y1Offset =
                    toFloat titleBarHeightPx + (columnBarHeightPx * offsetHelper fromColDesc fromColDescs)

                y2Offset : Float
                y2Offset =
                    toFloat titleBarHeightPx + (columnBarHeightPx * offsetHelper toColDesc toColDescs)

                ( y1Offset_, y2Offset_ ) =
                    if fromInfo.renderInfo.pos.x < toInfo.renderInfo.pos.x then
                        ( y1Offset, y2Offset )

                    else
                        ( y2Offset, y1Offset )

                --x2 : Float
                --x2 =
                --    max fromInfo.renderInfo.pos.x toInfo.renderInfo.pos.x
                --
                --y1 : Float
                --y1 =
                --    fromInfo.renderInfo.pos.y
                --
                --y2 : Float
                --y2 =
                --    toInfo.renderInfo.pos.y
                x1_ : Float
                x1_ =
                    if x2 > (x1 + (0.5 * erdCardWidth)) then
                        -- Move x1 to rhs of card
                        x1 + erdCardWidth
                        --x1

                    else
                        x1

                x2_ : Float
                x2_ =
                    if x1 > (x2 + (0.5 * erdCardWidth)) || (x2 > x1 + erdCardWidth) then
                        x2 + erdCardWidth

                    else
                        x2
            in
            ( { x = x1_ + 0, y = y1 + y1Offset_ }
            , { x = x2_, y = y2 + y2Offset_ }
            )

        tableInfosFromNodeId : NodeId -> Maybe DimModelDuckDbSourceInfo
        tableInfosFromNodeId nodeId =
            case columnDescFromNodeId graph nodeId of
                Just colDesc ->
                    Dict.get (ref_ToString colDesc.parentRef) tableInfos

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

        coords : List ( Position, Position )
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
    26



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
    , erdCardDropdownMenuProps : DropDownProps msg DuckDbRef Int
    }


viewErdSvgNodes : { r | theme : ColorTheme } -> Dict DuckDbRefString (ErdSvgNodeProps msg) -> DimensionalModel -> List (Svg msg)
viewErdSvgNodes r propsDict dimModel =
    viewSvgErdCards r propsDict dimModel ++ viewLines r dimModel



-- end region: exposed UI components
-- begin region: non-exposed UI components


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
                    desc.name
            in
            column
                [ width fill
                , height fill
                , Events.onMouseDown (erdCardProps.onBeginErdCardDrag duckDbRef_)
                ]
                (List.map
                    (\col ->
                        row
                            [ width fill
                            , paddingXY 5 3
                            , Events.onClick (erdCardProps.onClickedErdCardColumnRow duckDbRef_ col)
                            , Events.onMouseEnter (erdCardProps.onMouseEnteredErdCardColumnRow duckDbRef_ col)
                            ]
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
        , Events.onMouseEnter (erdCardProps.onMouseEnteredErdCard duckDbRef_)
        , Events.onMouseLeave erdCardProps.onMouseLeftErdCard
        ]
        [ viewCardTitleBar
        , viewCardBody
        ]



-- end region: non-exposed UI components
