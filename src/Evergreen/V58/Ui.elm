module Evergreen.V58.Ui exposing (..)

import Evergreen.V58.Element


type alias ColorTheme =
    { primary1 : Evergreen.V58.Element.Color
    , primary2 : Evergreen.V58.Element.Color
    , secondary : Evergreen.V58.Element.Color
    , background : Evergreen.V58.Element.Color
    , deadspace : Evergreen.V58.Element.Color
    , white : Evergreen.V58.Element.Color
    , gray : Evergreen.V58.Element.Color
    , black : Evergreen.V58.Element.Color
    , debugWarn : Evergreen.V58.Element.Color
    , debugAlert : Evergreen.V58.Element.Color
    , link : Evergreen.V58.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
