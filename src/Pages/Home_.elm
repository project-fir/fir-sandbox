module Pages.Home_ exposing (view)

import Element as E exposing (..)
import Element.Background as Background
import Element.Font as Font
import Ui exposing (theme)
import View exposing (View)


view : View msg
view =
    { title = "Home"
    , body =
        elements
    }


elements : Element msg
elements =
    el [] <|
        column
            [ Font.size 40
            , Font.color theme.black
            , width (px 600)
            , height fill
            , Background.color theme.background
            ]
            [ E.text "Fir" ]
