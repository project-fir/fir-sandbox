module Palette exposing (ColorTheme, PaletteTheme(..), theme, toAvhColor)

import Color as AvhColor
import Element exposing (Color, rgb255)



--begin region: theme definitions


type alias ColorTheme =
    { primary1 : Color
    , primary2 : Color
    , secondary : Color
    , background : Color
    , white : Color
    , black : Color
    , debugWarn : Color
    , debugAlert : Color
    }


type PaletteTheme
    = BambooBeach


selectedTheme =
    BambooBeach


theme : ColorTheme
theme =
    let
        decorateBaseTheme : { primary1 : Color, primary2 : Color, secondary : Color, background : Color } -> ColorTheme
        decorateBaseTheme base =
            { primary1 = base.primary1
            , primary2 = base.primary2
            , secondary = base.secondary
            , background = base.background
            , white = white
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
                }



-- end region: theme definitions
-- begin region: color definitions - bamboo beach theme
--           see: https://www.canva.com/colors/color-palettes/bamboo-beach/


cream : Color
cream =
    rgb255 0xFB 0xF6 0xF3


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


black : Color
black =
    rgb255 0x00 0x00 0x00



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
