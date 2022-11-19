module Pages.Stories.Basics exposing (view)

import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Palette exposing (ColorTheme, PaletteName(..), theme, themeOf)
import View exposing (View)


view : View msg
view =
    { title = "Basics"
    , body = el [ Font.size 19, Background.color theme.deadspace, width fill, height fill ] elements
    }


swatchSize =
    140


viewDropDown : Element msg
viewDropDown =
    E.none


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
                , Font.size 24
                ]
            <|
                row [ padding 5, width fill ]
                    [ el [ alignLeft, Font.bold ] (E.text "Basics")
                    , el [ Font.size 14, alignRight ] (E.text "Use this dropdown! -->")
                    , viewDropDown
                    ]

        viewSwatch : Color -> String -> Element msg
        viewSwatch col displayText =
            el
                [ width (px swatchSize)
                , height (px swatchSize)
                , Background.color col
                ]
                (el [ centerX, centerY, Font.size 8 ] (E.text displayText))

        viewThemeSwatches : ColorTheme -> Element msg
        viewThemeSwatches theme_ =
            column [ height fill, width fill ]
                [ row
                    [ width fill
                    , height (px (swatchSize + 10))
                    , spaceEvenly
                    ]
                    [ viewSwatch theme_.primary1 "Primary 1"
                    , viewSwatch theme_.primary2 "Primary 2"
                    , viewSwatch theme_.secondary "Secondary"
                    , viewSwatch theme_.background "Background"
                    , viewSwatch theme_.deadspace "DeadSpace"
                    ]
                ]

        viewCommonSwatches : ColorTheme -> Element msg
        viewCommonSwatches theme_ =
            row
                [ height (px (swatchSize + 10))
                , width fill
                , spaceEvenly
                , centerX
                ]
                [ viewSwatch theme_.white "white"
                , viewSwatch theme_.gray "gray"
                , viewSwatch theme_.black "black"
                ]
    in
    el
        [ Font.color theme.black
        , width (fill |> minimum 400 |> maximum 800)
        , height fill
        , Background.color theme.background

        --, Border.width 1
        --, Border.color theme.secondary
        , centerX
        ]
        (column
            [ width fill
            , centerX
            , padding 10
            ]
            [ viewHeader
            , el [ padding 5 ] <| E.text "Theme swatches:"
            , viewThemeSwatches (themeOf BambooBeach)
            , viewThemeSwatches (themeOf CoffeeRun)
            , viewThemeSwatches (themeOf Nitro)
            , el [ padding 5 ] <| E.text "Common swatches:"
            , viewCommonSwatches (themeOf BambooBeach)
            ]
        )
