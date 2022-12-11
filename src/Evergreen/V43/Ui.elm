module Evergreen.V43.Ui exposing (..)

import Evergreen.V43.Element


type alias ColorTheme =
    { primary1 : Evergreen.V43.Element.Color
    , primary2 : Evergreen.V43.Element.Color
    , secondary : Evergreen.V43.Element.Color
    , background : Evergreen.V43.Element.Color
    , deadspace : Evergreen.V43.Element.Color
    , white : Evergreen.V43.Element.Color
    , gray : Evergreen.V43.Element.Color
    , black : Evergreen.V43.Element.Color
    , debugWarn : Evergreen.V43.Element.Color
    , debugAlert : Evergreen.V43.Element.Color
    , link : Evergreen.V43.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
