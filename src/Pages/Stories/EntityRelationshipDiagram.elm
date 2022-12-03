module Pages.Stories.EntityRelationshipDiagram exposing (Model, Msg, page)

import Dict exposing (Dict)
import DimensionalModel exposing (DimModelDuckDbSourceInfo, KimballAssignment(..))
import DuckDb exposing (DuckDbRef, DuckDbRefString, DuckDbRef_(..), refToString)
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
import Ui exposing (ColorTheme, toAvhColor)
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
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    let
        dimRef : DuckDbRef
        dimRef =
            { schemaName = "story", tableName = "some_dim" }

        factRef : DuckDbRef
        factRef =
            { schemaName = "story", tableName = "some_fact" }
    in
    ( { theme = shared.selectedTheme
      , tableInfos =
            Dict.fromList
                [ ( refToString dimRef
                  , { renderInfo =
                        { pos = { x = 100.0, y = 100.0 }
                        , ref = dimRef
                        }
                    , assignment = Dimension (DuckDbTable dimRef) []
                    , isIncluded = True
                    }
                  )
                , ( refToString factRef
                  , { renderInfo =
                        { pos = { x = 200.0, y = 200.0 }
                        , ref = dimRef
                        }
                    , assignment = Dimension (DuckDbTable dimRef) []
                    , isIncluded = True
                    }
                  )
                ]
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Stories - ERD"
    , body = viewElements model
    }


viewElements : Model -> Element Msg
viewElements model =
    el [ width fill, height fill, Background.color model.theme.deadspace, padding 5 ] <|
        column
            [ height fill
            , width (px 800)
            , padding 5
            , Background.color model.theme.background
            , centerX
            ]
            [ viewCanvas model
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
        , Border.color model.theme.black
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
                [ S.rect
                    [ SA.x (ST.px 0)
                    , SA.y (ST.px 0)
                    , SA.width (ST.px width_)
                    , SA.height (ST.px height_)
                    ]
                    (viewSvgNodes model)
                ]


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
                    viewEntityRelationshipCard
                ]
    in
    List.map (\info -> foreignObjectHelper info) (Dict.values model.tableInfos)


viewEntityRelationshipCard : Element Msg
viewEntityRelationshipCard =
    E.text "This is a elm-ui card!"
