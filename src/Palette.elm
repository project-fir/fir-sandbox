module Palette exposing (ColorTheme, PaletteTheme(..), theme, toAvhColor)

import Color as AvhColor
import Element exposing (Color, rgb255)



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


type PaletteTheme
    = BambooBeach
    | CoffeeRun


selectedTheme =
    BambooBeach


theme : ColorTheme
theme =
    let
        decorateBaseTheme :
            { primary1 : Color
            , primary2 : Color
            , secondary : Color
            , background : Color
            , deadspace : Color
            , link : Color
            }
            -> ColorTheme
        decorateBaseTheme base =
            { primary1 = base.primary1
            , primary2 = base.primary2
            , secondary = base.secondary
            , background = base.background
            , deadspace = base.deadspace
            , link = base.link
            , white = white
            , gray = gray
            , black = black
            , debugWarn = orange
            , debugAlert = red
            }
    in
    case selectedTheme of
        BambooBeach ->
            decorateBaseTheme
                { primary1 = tangerine
                , primary2 = turquoise
                , secondary = blueGray
                , background = cream
                , deadspace = bambooDeadSpace
                , link = blue
                }

        CoffeeRun ->
            decorateBaseTheme
                { primary1 = blueGreen
                , primary2 = brown2
                , secondary = cornflower
                , background = brown1
                , deadspace = coffeeDeadSpace
                , link = coffeeLink
                }



-- end region: theme definitions
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
    blue


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


blue : Color
blue =
    rgb255 0x34 0xA7 0xC6



-- end region: color definitions - commons
-- begin region: utils


toAvhColor : Element.Color -> AvhColor.Color
toAvhColor color =
    -- I typically work with Element.Color in UIs, but Svg gets along better with Avh's Color,
    -- so to keep the palette defined in one place, transform between the two
    let
        rgba =
            Element.toRgb color
    in
    AvhColor.rgba rgba.red rgba.green rgba.blue rgba.alpha



-- end region: utils
