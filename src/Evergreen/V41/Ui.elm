module Evergreen.V41.Ui exposing (..)

import Evergreen.V41.Element


type alias ColorTheme =
    { primary1 : Evergreen.V41.Element.Color
    , primary2 : Evergreen.V41.Element.Color
    , secondary : Evergreen.V41.Element.Color
    , background : Evergreen.V41.Element.Color
    , deadspace : Evergreen.V41.Element.Color
    , white : Evergreen.V41.Element.Color
    , gray : Evergreen.V41.Element.Color
    , black : Evergreen.V41.Element.Color
    , debugWarn : Evergreen.V41.Element.Color
    , debugAlert : Evergreen.V41.Element.Color
    , link : Evergreen.V41.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
