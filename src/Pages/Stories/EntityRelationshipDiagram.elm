module Pages.Stories.EntityRelationshipDiagram exposing (Model, Msg, page)

import Dict exposing (Dict)
import DimensionalModel exposing (DimModelDuckDbSourceInfo, KimballAssignment(..))
import DuckDb exposing (DuckDbColumnDescription(..), DuckDbRef, DuckDbRefString, DuckDbRef_(..), refToString)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Stories.EntityRelationshipDiagram exposing (Params)
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
    , tableInfos : Dict DuckDbRefString DimModelDuckDbSourceInfo
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
    in
    ( { theme = shared.selectedTheme
      , tableInfos =
            Dict.fromList
                [ ( refToString dimRef
                  , { renderInfo =
                        { pos = { x = 40.0, y = 150.0 }
                        , ref = dimRef
                        , isDrawerOpen = False
                        }
                    , assignment = Dimension (DuckDbTable dimRef) dimCols
                    , isIncluded = True
                    }
                  )
                , ( refToString factRef
                  , { renderInfo =
                        { pos = { x = 400.0, y = 50.0 }
                        , ref = factRef
                        , isDrawerOpen = False
                        }
                    , assignment = Fact (DuckDbTable factRef) factCols
                    , isIncluded = True
                    }
                  )
                ]
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
                    case Dict.get (refToString ref) model.tableInfos of
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
                            Dict.insert (refToString ref) tableInfos_ model.tableInfos

                        Nothing ->
                            model.tableInfos
            in
            ( { model
                | msgHistory = msg :: model.msgHistory
                , tableInfos = newTableInfos
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
                (viewSvgNodes model)


erdCardWidth =
    250


erdCardHeight =
    400


viewSvgNodes : Model -> List (Svg Msg)
viewSvgNodes model =
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
    List.map (\info -> foreignObjectHelper info) (Dict.values model.tableInfos)


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
                    case Dict.get (refToString duckDbRef_) model.tableInfos of
                        Just info ->
                            info.renderInfo.isDrawerOpen

                        Nothing ->
                            False

                dropDownProps : DropDownProps Msg
                dropDownProps =
                    { isOpen = isDrawOpen
                    , widthPx = 25
                    , heightPx = titleBarHeightPx
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
            row
                [ width fill
                , height (px titleBarHeightPx)
                , Border.width 1
                , Border.color model.theme.black
                ]
                [ E.text (refToString duckDbRef_)
                , el [ alignRight ] <| dropdownMenu model dropDownProps
                ]

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
    in
    column
        [ width (px 250)
        , height (px 250)
        , Background.color computedBackgroundColor
        ]
        [ viewCardTitleBar
        , viewCardBody
        ]
