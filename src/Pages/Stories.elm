module Pages.Stories exposing (view)

import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Ui exposing (theme)
import View exposing (View)


view : View msg
view =
    { title = "Stories"
    , body = el [ Background.color theme.deadspace, width fill, height fill ] elements
    }


elements : Element msg
elements =
    let
        viewHeader : Element msg
        viewHeader =
            el
                [ width fill
                , height fill
                , alignLeft
                , Border.widthEach { top = 0, left = 0, right = 0, bottom = 3 }
                , Border.color theme.secondary
                ]
            <|
                el [ padding 5 ] <|
                    E.text "Select a story for visual QA"

        viewStoryList : Element msg
        viewStoryList =
            column
                [ width fill
                , height fill
                , Background.color theme.background
                , spacing 10
                , padding 10
                , Font.size 16
                ]
                [ paragraph []
                    [ link [ Font.color theme.link ]
                        { url = "/stories/basics"
                        , label = text "/basics"
                        }
                    , E.text " - story for theme color swatches, and basic components like buttons, drop-downs, etc."
                    ]
                , paragraph []
                    [ link [ Font.color theme.link ]
                        { url = "/stories/entity-relationship-diagram"
                        , label = text "/entity-relationship-diagram"
                        }
                    , E.text " - story for (partially) componentized entity relationship diagram"
                    ]
                , paragraph []
                    [ link [ Font.color theme.link ]
                        { url = "/stories/text-editor"
                        , label = text "/text-editor"
                        }
                    , E.text " - story for testing text-editor features"
                    ]
                , paragraph []
                    [ link [ Font.color theme.link ]
                        { url = "/stories/fir-lang"
                        , label = text "/fir-lang"
                        }
                    , E.text " - story for defining Fir"
                    ]
                ]
    in
    el
        [ Font.size 24
        , Font.color theme.black
        , width (fill |> minimum 400 |> maximum 800)
        , height fill
        , Background.color theme.background

        --, Border.width 1
        --, Border.color theme.secondary
        , centerX
        ]
        (column [ width fill, centerX, padding 10 ]
            [ viewHeader
            , viewStoryList
            ]
        )
