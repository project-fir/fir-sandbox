module Pages.NotFound exposing (view)

import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Border as Border
import Element.Font as Font
import Gen.Params.NotFound exposing (Params)
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


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    ( { theme = shared.selectedTheme
      }
    , Effect.none
    )


type Msg
    = -- NB: This module's Msg type needs to exist to make elm-spa happy
      --     This is due to pulling from Shared.Model for theme
      Noop


type alias Model =
    { theme : ColorTheme
    }


update : Msg -> Model -> ( Model, Effect Msg )
update _ model =
    ( model, Effect.none )


linkAttrs : Model -> List (Attr () Msg)
linkAttrs model =
    [ Font.color model.theme.link, Font.underline ]


view : Model -> View Msg
view model =
    { title = "404 Not Found"
    , body =
        viewElements model
    }


viewElements : Model -> Element Msg
viewElements model =
    el
        [ width fill
        , height fill
        , padding 10
        ]
        (column
            [ width (px 600)
            , height fill
            , centerX
            , centerY
            , Font.size 20
            , Border.width 0
            , Border.color model.theme.secondary
            , spacing 10
            ]
            [ paragraph [ centerY ] [ E.text "The page you requested does not exist!" ]
            , paragraph [ centerY ]
                [ E.text "Feel free to check out the "
                , link (linkAttrs model)
                    { url = "/stories"
                    , label = text "stories"
                    }
                , E.text " or the "
                , link
                    (linkAttrs model)
                    { url = "/"
                    , label = text "homepage"
                    }
                ]
            ]
        )
