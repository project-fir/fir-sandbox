module Evergreen.V50.Ui exposing (..)

import Evergreen.V50.Element


type alias ColorTheme =
    { primary1 : Evergreen.V50.Element.Color
    , primary2 : Evergreen.V50.Element.Color
    , secondary : Evergreen.V50.Element.Color
    , background : Evergreen.V50.Element.Color
    , deadspace : Evergreen.V50.Element.Color
    , white : Evergreen.V50.Element.Color
    , gray : Evergreen.V50.Element.Color
    , black : Evergreen.V50.Element.Color
    , debugWarn : Evergreen.V50.Element.Color
    , debugAlert : Evergreen.V50.Element.Color
    , link : Evergreen.V50.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
