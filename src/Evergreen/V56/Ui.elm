module Evergreen.V56.Ui exposing (..)

import Evergreen.V56.Element


type alias ColorTheme =
    { primary1 : Evergreen.V56.Element.Color
    , primary2 : Evergreen.V56.Element.Color
    , secondary : Evergreen.V56.Element.Color
    , background : Evergreen.V56.Element.Color
    , deadspace : Evergreen.V56.Element.Color
    , white : Evergreen.V56.Element.Color
    , gray : Evergreen.V56.Element.Color
    , black : Evergreen.V56.Element.Color
    , debugWarn : Evergreen.V56.Element.Color
    , debugAlert : Evergreen.V56.Element.Color
    , link : Evergreen.V56.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
