module Ui exposing (ButtonProps, ColorTheme, DropDownOption, DropDownOptionId, DropDownProps, PaletteName(..), button, dropdownMenu, theme, themeOf, toAvhColor)

import Color as AvhColor
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input



--begin region: theme definitions


type alias ColorTheme =
    { primary1 : Color
    , primary2 : Color
    , secondary : Color
    , background : Color
    , deadspace : Color
    , white : Color
    , gray : Color
    , black : Color
    , debugWarn : Color
    , debugAlert : Color
    , link : Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro


selectedTheme : PaletteName
selectedTheme =
    -- TODO: Remove this in favor of the logic in Shared, thread through to all the pages.
    Nitro


theme : ColorTheme
theme =
    -- NB: This is the primary function exposed in this module
    themeOf selectedTheme


themeOf : PaletteName -> ColorTheme
themeOf palette =
    -- NB: This is a helper function only exposed for visual QA purposes, see /stories. All potentially user-executed
    --     code should use the theme function, not this function!
    let
        decorateBaseTheme :
            { primary1 : Color
            , primary2 : Color
            , secondary : Color
            , background : Color
            , deadSpace : Color
            , link : Color
            }
            -> ColorTheme
        decorateBaseTheme base =
            { primary1 = base.primary1
            , primary2 = base.primary2
            , secondary = base.secondary
            , background = base.background
            , deadspace = base.deadSpace
            , link = base.link
            , white = white
            , gray = gray
            , black = black
            , debugWarn = orange
            , debugAlert = red
            }
    in
    case palette of
        BambooBeach ->
            decorateBaseTheme
                { primary1 = tangerine
                , primary2 = turquoise
                , secondary = blueGray
                , background = cream
                , deadSpace = bambooDeadSpace
                , link = bambooLink
                }

        CoffeeRun ->
            decorateBaseTheme
                { primary1 = blueGreen
                , primary2 = brown2
                , secondary = cornflower
                , background = brown1
                , deadSpace = coffeeDeadSpace
                , link = coffeeLink
                }

        Nitro ->
            decorateBaseTheme
                { primary1 = yellowNitro
                , primary2 = mediumAquamarine
                , secondary = nitroSecondary
                , background = seaGreenCrayola
                , deadSpace = babyPowder
                , link = nitroLink
                }



-- end region: theme definitions
-- begin region: color definitions - nitro theme


nitroSecondary : Color
nitroSecondary =
    rgb255 0x52 0x77 0xC7


seaGreenCrayola : Color
seaGreenCrayola =
    white


mediumAquamarine : Color
mediumAquamarine =
    rgb255 0x6D 0xEC 0xAF


babyPowder : Color
babyPowder =
    rgb255 0xF4 0xF4 0xED


yellowNitro : Color
yellowNitro =
    rgb255 0xFE 0xD7 0x66


nitroLink : Color
nitroLink =
    rgb255 0xF6 0x10 0x67



-- end region: color definitions - nitro theme
--begin region: color definitions - coffee run theme
-- TODO: coffee run theme is trash, but it highlights overuse of background colors.


blueGreen : Color
blueGreen =
    rgb255 0x39 0x91 0x8C


brown1 : Color
brown1 =
    rgb255 0xD0 0xB4 0x9F


brown2 : Color
brown2 =
    rgb255 0xAB 0x6B 0x51


cornflower : Color
cornflower =
    rgb255 0x2F 0x43 0x5A


coffeeDeadSpace : Color
coffeeDeadSpace =
    rgb255 0xC8 0xA8 0x8F


coffeeLink : Color
coffeeLink =
    rgb255 0x14 0x60 0xBF



-- end region: color definitions - coffee run theme
-- begin region: color definitions - bamboo beach theme
--           see: https://www.canva.com/colors/color-palettes/bamboo-beach/


cream : Color
cream =
    rgb255 0xFB 0xF6 0xF3


bambooDeadSpace : Color
bambooDeadSpace =
    rgb255 0xF7 0xED 0xE7


bambooLink : Color
bambooLink =
    rgb255 0x34 0xA7 0xC6


tangerine : Color
tangerine =
    rgb255 0xFE 0xB0 0x6A


turquoise : Color
turquoise =
    rgb255 0x36 0xD6 0xE7


blueGray : Color
blueGray =
    rgb255 0x5D 0x6C 0x89



-- end region: color definitions - bamboo beach theme
-- begin region: color definitions - debug colors
-- these colors are generic, should be used for development purposes, like elm-ui debugging


red : Color
red =
    rgb255 0xFF 0x12 0x10


orange : Color
orange =
    rgb255 0xFC 0x8F 0x32



-- end region: color definitions - debug colors
-- begin region: color definitions - commons
-- these colors are generic / will likely be present in all themes


white : Color
white =
    rgb255 0xFF 0xFF 0xFF


gray : Color
gray =
    rgb255 0xE3 0xE3 0xE6


black : Color
black =
    rgb255 0x00 0x00 0x00



-- end region: color definitions - commons
-- begin region: utils


toAvhColor : E.Color -> AvhColor.Color
toAvhColor color =
    -- I typically work with Element.Color in UIs, but Svg gets along better with Avh's Color,
    -- so to keep the palette defined in one place, transform between the two
    let
        rgba =
            E.toRgb color
    in
    AvhColor.rgba rgba.red rgba.green rgba.blue rgba.alpha



-- end region: utils
-- begin region: drop-down component


type alias DropDownOptionId =
    Int


type alias DropDownProps msg menuId =
    { isOpen : Bool
    , id : menuId
    , widthPx : Int
    , heightPx : Int
    , onDrawerClick : menuId -> msg
    , onMenuMouseEnter : menuId -> msg
    , onMenuMouseLeave : menuId -> msg
    , isMenuHovered : Bool
    , menuBarText : String
    , options : List (DropDownOption msg)
    , hoveredOnOption : Maybe DropDownOptionId
    }


type alias DropDownOption msg =
    { displayText : String
    , optionId : DropDownOptionId
    , onClick : msg
    , onHover : msg
    }


dropdownMenu : { r | theme : ColorTheme } -> DropDownProps msg menuId -> Element msg
dropdownMenu r props =
    let
        menuOption : DropDownOption msg -> Element msg
        menuOption op =
            let
                bkgdColor : Color
                bkgdColor =
                    case props.hoveredOnOption of
                        Nothing ->
                            r.theme.background

                        Just opId ->
                            if opId == op.optionId then
                                r.theme.secondary

                            else
                                r.theme.background
            in
            el
                (attrs bkgdColor ++ [ Events.onClick op.onClick, Events.onMouseLeave op.onHover ])
                (E.text op.displayText)

        attrs : Color -> List (Attribute msg)
        attrs bkgdColor =
            [ Border.width 1
            , Border.color r.theme.secondary
            , Background.color bkgdColor
            , height (px props.heightPx)
            , width (px props.widthPx)
            , padding 2
            , width fill
            ]

        menuHeader : Element msg
        menuHeader =
            let
                backgroundColor : Color
                backgroundColor =
                    case props.isMenuHovered of
                        True ->
                            r.theme.secondary

                        False ->
                            r.theme.background
            in
            el
                (attrs backgroundColor
                    ++ [ Events.onClick <| props.onDrawerClick props.id
                       , Events.onMouseEnter <| props.onMenuMouseEnter props.id
                       , Events.onMouseLeave <| props.onMenuMouseLeave props.id
                       ]
                )
                (row [ centerY, height fill, padding 0 ]
                    [ el [ alignLeft ] <| E.text props.menuBarText
                    , el
                        [ height fill
                        , alignRight
                        ]
                        (el
                            [ centerY
                            , Border.color r.theme.secondary
                            , Border.width 1
                            ]
                         <|
                            E.text "▼"
                        )
                    ]
                )

        drawer : Element msg
        drawer =
            case props.isOpen of
                True ->
                    el
                        [ below
                            (column [] (List.map (\o -> menuOption o) props.options))
                        ]
                        menuHeader

                False ->
                    menuHeader
    in
    -- I don't fully understand why, but wrapping in this top-level el results in a better behaved width
    el [ width (px props.widthPx), height (px props.heightPx) ] drawer



-- end region: drop-down component
-- begin region: button component


type alias ButtonProps msg =
    { onClick : Maybe msg
    , displayText : String
    }


button : { r | theme : ColorTheme } -> ButtonProps msg -> Element msg
button r props =
    Input.button []
        { onPress = props.onClick
        , label =
            el
                [ Border.width 1
                , Border.color r.theme.secondary
                , Background.color r.theme.primary2
                , Border.rounded 3
                , padding 3
                ]
                (E.text props.displayText)
        }



-- end region: button component
