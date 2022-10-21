module Pages.Home_ exposing (view)

import Element as E exposing (..)
import View exposing (View)


view : View msg
view =
    { title = "Homepage"
    , body =
        elements
    }


elements : Element msg
elements =
    E.text "Homepage placeholder"
