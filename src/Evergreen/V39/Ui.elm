module Evergreen.V39.Ui exposing (..)

import Evergreen.V39.Element


type alias ColorTheme =
    { primary1 : Evergreen.V39.Element.Color
    , primary2 : Evergreen.V39.Element.Color
    , secondary : Evergreen.V39.Element.Color
    , background : Evergreen.V39.Element.Color
    , deadspace : Evergreen.V39.Element.Color
    , white : Evergreen.V39.Element.Color
    , gray : Evergreen.V39.Element.Color
    , black : Evergreen.V39.Element.Color
    , debugWarn : Evergreen.V39.Element.Color
    , debugAlert : Evergreen.V39.Element.Color
    , link : Evergreen.V39.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
