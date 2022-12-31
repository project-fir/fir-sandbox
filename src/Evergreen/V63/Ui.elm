module Evergreen.V63.Ui exposing (..)

import Evergreen.V63.Element


type alias ColorTheme =
    { primary1 : Evergreen.V63.Element.Color
    , primary2 : Evergreen.V63.Element.Color
    , secondary : Evergreen.V63.Element.Color
    , background : Evergreen.V63.Element.Color
    , deadspace : Evergreen.V63.Element.Color
    , white : Evergreen.V63.Element.Color
    , gray : Evergreen.V63.Element.Color
    , black : Evergreen.V63.Element.Color
    , debugWarn : Evergreen.V63.Element.Color
    , debugAlert : Evergreen.V63.Element.Color
    , link : Evergreen.V63.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
