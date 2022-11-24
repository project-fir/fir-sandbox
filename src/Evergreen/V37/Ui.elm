module Evergreen.V37.Ui exposing (..)

import Evergreen.V37.Element


type alias ColorTheme =
    { primary1 : Evergreen.V37.Element.Color
    , primary2 : Evergreen.V37.Element.Color
    , secondary : Evergreen.V37.Element.Color
    , background : Evergreen.V37.Element.Color
    , deadspace : Evergreen.V37.Element.Color
    , white : Evergreen.V37.Element.Color
    , gray : Evergreen.V37.Element.Color
    , black : Evergreen.V37.Element.Color
    , debugWarn : Evergreen.V37.Element.Color
    , debugAlert : Evergreen.V37.Element.Color
    , link : Evergreen.V37.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
