module Evergreen.V65.Ui exposing (..)

import Evergreen.V65.Element


type alias ColorTheme =
    { primary1 : Evergreen.V65.Element.Color
    , primary2 : Evergreen.V65.Element.Color
    , secondary : Evergreen.V65.Element.Color
    , background : Evergreen.V65.Element.Color
    , deadspace : Evergreen.V65.Element.Color
    , white : Evergreen.V65.Element.Color
    , gray : Evergreen.V65.Element.Color
    , black : Evergreen.V65.Element.Color
    , debugWarn : Evergreen.V65.Element.Color
    , debugAlert : Evergreen.V65.Element.Color
    , link : Evergreen.V65.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
