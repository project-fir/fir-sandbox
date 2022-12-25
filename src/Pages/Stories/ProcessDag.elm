module Pages.Stories.ProcessDag exposing (Model, Msg, page)

import DimensionalModel exposing (LineSegment, PositionPx)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Gen.Params.Stories.ProcessDag exposing (Params)
import Page
import Request
import Shared
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Simple.Animation.Property as P
import TypedSvg as S
import TypedSvg.Attributes as SA
import TypedSvg.Core as SC exposing (Svg)
import TypedSvg.Types as ST
import Ui exposing (ColorTheme, toAvhColor)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared _ =
    Page.advanced
        { init = init shared
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { theme : ColorTheme
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    ( { theme = shared.selectedTheme
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
    { title = "Story | Process DAG"
    , body = el [ width fill, height fill, Background.color model.theme.deadspace, padding 5 ] <| viewElements model
    }


viewDebugInfo : Model -> Element Msg
viewDebugInfo model =
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
        ]


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
        width_ : number
        width_ =
            600

        height_ : number
        height_ =
            400
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
                (svgNodeWithAnimation model ( { x = 150, y = 100 }, { x = 350, y = 200 } )
                    :: svgNodeWithAnimation model ( { x = 150, y = 300 }, { x = 350, y = 200 } )
                    :: viewDagSvgNodes model
                )


runToLoop : LineSegment -> Animation
runToLoop lineSegment =
    let
        ( srcPos, destPos ) =
            ( Tuple.first lineSegment, Tuple.second lineSegment )
    in
    Animation.steps
        { startAt = [ P.x srcPos.x, P.y srcPos.y ]
        , options = [ Animation.loop ]
        }
        [ Animation.step 750 [ P.x destPos.x, P.y destPos.y ]
        , Animation.wait 250
        ]


svgNodeWithAnimation : { r | theme : ColorTheme } -> LineSegment -> Svg msg
svgNodeWithAnimation r lineSegment =
    let
        runnerAnimation : Animation
        runnerAnimation =
            runToLoop lineSegment
    in
    animatedCircle runnerAnimation
        [ SA.rx (ST.px 10)
        , SA.stroke (ST.Paint (toAvhColor r.theme.primary2))
        , SA.fill (ST.Paint (toAvhColor r.theme.primary1))
        ]
        []


animatedCircle : Animation -> List (SC.Attribute msg) -> List (SC.Svg msg) -> SC.Svg msg
animatedCircle animation =
    animatedTypedSvg S.ellipse animation


animatedTypedSvg :
    (List (SC.Attribute msg) -> List (SC.Svg msg) -> SC.Svg msg)
    -> Animation
    -> List (SC.Attribute msg)
    -> List (SC.Svg msg)
    -> SC.Svg msg
animatedTypedSvg node animation attributes children =
    Animated.custom
        (\className stylesheet ->
            node
                (SA.class [ className ] :: attributes)
                (S.style [] [ SC.text stylesheet ] :: children)
        )
        animation


viewDagSvgNodes : Model -> List (Svg Msg)
viewDagSvgNodes model =
    [ S.rect
        [ SA.x (ST.px 50)
        , SA.y (ST.px 50)
        , SA.width (ST.px 100)
        , SA.height (ST.px 100)
        , SA.rx (ST.px 15)
        , SA.stroke (ST.Paint (toAvhColor model.theme.secondary))
        , SA.fill (ST.Paint (toAvhColor model.theme.white))
        ]
        []
    , S.rect
        [ SA.x (ST.px 50)
        , SA.y (ST.px 250)
        , SA.width (ST.px 100)
        , SA.height (ST.px 100)
        , SA.rx (ST.px 15)
        , SA.stroke (ST.Paint (toAvhColor model.theme.secondary))
        , SA.fill (ST.Paint (toAvhColor model.theme.white))
        ]
        []
    , S.rect
        [ SA.x (ST.px 350)
        , SA.y (ST.px 150)
        , SA.width (ST.px 100)
        , SA.height (ST.px 100)
        , SA.rx (ST.px 15)
        , SA.stroke (ST.Paint (toAvhColor model.theme.secondary))
        , SA.fill (ST.Paint (toAvhColor model.theme.white))
        ]
        []
    , S.line
        [ SA.x1 (ST.px 150)
        , SA.y1 (ST.px 100)
        , SA.x2 (ST.px 350)
        , SA.y2 (ST.px 200)
        , SA.stroke (ST.Paint (toAvhColor model.theme.black))
        ]
        []
    , S.line
        [ SA.x1 (ST.px 150)
        , SA.y1 (ST.px 300)
        , SA.x2 (ST.px 350)
        , SA.y2 (ST.px 200)
        , SA.stroke (ST.Paint (toAvhColor model.theme.black))
        ]
        []
    ]



-- begin region: ERD Card constants
-- NB: These constants are shared among several functions in this story, but are not intended to be exposed
--     if you think you need to expose, I recommend first trying to implement the functionality in this module
-- end region: ERD Card constants
-- begin region: exposed UI components


type alias ProcessDagProps =
    { id : String
    }



-- end region: exposed UI components
-- begin region: non-exposed UI components
-- end region: non-exposed UI components


s =
    """
Process Dag

What do I mean by a process dag?

Ideally, it should be a model of a business process.

Let's use Smith's example of a pin factory, what are the things needed

 * Capital
 * Raw materials, mining
 * Miners
 * Raw materials, shipping to factory
 * Truckers
 * Labor in factory
 * The factory has design / stations
 * Shipments get sent to retail depot
 * Truckers from
 * customer buys in store
 * customers
 * store clerks

What are the facts and dimensions of this business process?

balance sheet - is this inferred?
mines
employees
payroll
raw materials
depot stock piles
distribution to retail depots
customers


 - dim_employee
   * employee_id, boomerangs get new row
   * of sub-dims: miner, factory worker, trucker, store clerks
   * name
   * dob
   * current_hourly_wage_usd - this could be a slowly-changing dimension
   * employment_depot
   * start_end
   * end_date


While I grouped all employees together in one dim table, I would think
there
 - dim_geo (let's be America-centric for now)
  * geo_id
  * state
  * city
  * region

 - dim_mine
  *

 - dim_factory
  *

 - dim_store
  *
 - dim_customers
 *

 - fact_mined_ore
  * mine_id
  * weight_us_tons
  * date


entities:
 * ore
 * employees
 * products
 * customers
 * money?

facts:
 * ore is mined
 * ore is shipped
 * ore is "cleansed", there's a better word for that
 * product is manufactured
 * product is shipped to store
 * product sells, maybe
 * product collect dust
"""
