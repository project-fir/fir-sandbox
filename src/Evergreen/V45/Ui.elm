module Evergreen.V45.Ui exposing (..)

import Evergreen.V45.Element


type alias ColorTheme =
    { primary1 : Evergreen.V45.Element.Color
    , primary2 : Evergreen.V45.Element.Color
    , secondary : Evergreen.V45.Element.Color
    , background : Evergreen.V45.Element.Color
    , deadspace : Evergreen.V45.Element.Color
    , white : Evergreen.V45.Element.Color
    , gray : Evergreen.V45.Element.Color
    , black : Evergreen.V45.Element.Color
    , debugWarn : Evergreen.V45.Element.Color
    , debugAlert : Evergreen.V45.Element.Color
    , link : Evergreen.V45.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
