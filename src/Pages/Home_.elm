module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Gen.Params.Home_ exposing (Params)
import Page
import Request
import Shared
import Ui exposing (ColorTheme)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared _ =
    Page.advanced
        { init = init shared
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = -- NB: This module's Msg type needs to exist to make elm-spa happy
      --     This is due to pulling from Shared.Model for theme
      Noop


type alias Model =
    { theme : ColorTheme
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    ( { theme = shared.selectedTheme
      }
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update _ model =
    ( model, Effect.none )


view : Model -> View Msg
view model =
    { title = "Fir - Home"
    , body = viewElements model
    }


viewElements : Model -> Element Msg
viewElements model =
    el
        [ width fill
        , height fill
        , padding 10
        , Background.color model.theme.deadspace
        ]
    <|
        column
            [ height fill
            , width fill
            , centerX
            , Background.color model.theme.background
            , padding 5
            , spacing 10
            , Font.size 20
            ]
            [ paragraph
                [ Font.size 36
                , Font.underline
                , Font.bold
                , width (px 60)
                , centerX
                , centerY
                ]
                [ el [ centerX, width fill ] (E.text "Fir")
                ]
            , paragraph [ width (px 600), centerX, centerY ]
                [ E.text "What happens when you mix SmallTalk, Excel, P5, and DuckDB with a purely functional semantic layer? I don't know either! But I'm on a journey to find out!"
                ]
            , paragraph [ width (px 600), centerX, centerY ]
                [ E.text "In the meantime, check out the "
                , link [ Font.color model.theme.link, Font.underline ] { url = "/stories", label = E.text "stories" }
                , E.text ", and "
                , link [ Font.color model.theme.link, Font.underline ] { url = "https://www.twitter.com/rob_soko", label = E.text "stay tuned" }
                , E.text ". Blog posts coming!"
                ]
            , el [] (E.text " ")
            , el [] (E.text " ")
            , el [] (E.text " ")
            , el [] (E.text " ")
            , el [] (E.text " ")
            , el [] (E.text " ")
            ]


text =
    """

In the meantime, check out the stories, and stay tuned for blog posts
"""
