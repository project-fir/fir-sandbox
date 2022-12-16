module Pages.NotFound exposing (view)

import Element as E exposing (..)
import Element.Font as Font
import View exposing (View)


view : View msg
view =
    { title = "404 Not Found"
    , body =
        viewElements
    }


blueGray : Color
blueGray =
    rgb255 0x5D 0x6C 0x89


linkAttrs : List (Attr () msg)
linkAttrs =
    [ Font.color blueGray, Font.underline ]


viewElements : Element msg
viewElements =
    el [ width fill, height fill ]
        (column
            [ width (px 600)
            , height fill
            , centerX
            , Font.size 20
            ]
            [ E.text "The page you requested does not exist"
            , paragraph []
                [ E.text "Feel free to check out the "
                , link linkAttrs
                    { url = "/stories"
                    , label = text "stories"
                    }
                , E.text " or the "
                , link
                    linkAttrs
                    { url = "/"
                    , label = text "homepage"
                    }
                ]
            ]
        )
