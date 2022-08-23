module Pages.Home_ exposing (view)

import Color as C exposing (..)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html
import Palette
import View exposing (View)


view : View msg
view =
    { title = "Homepage"
    , body =
        [ layout
            [ padding 2
            , Font.size 16
            ]
            elements
        ]
    }


elements : Element msg
elements =
    E.text "Homepage placeholder"
