module Evergreen.V36.Ui exposing (..)

import Evergreen.V36.Element


type alias ColorTheme =
    { primary1 : Evergreen.V36.Element.Color
    , primary2 : Evergreen.V36.Element.Color
    , secondary : Evergreen.V36.Element.Color
    , background : Evergreen.V36.Element.Color
    , deadspace : Evergreen.V36.Element.Color
    , white : Evergreen.V36.Element.Color
    , gray : Evergreen.V36.Element.Color
    , black : Evergreen.V36.Element.Color
    , debugWarn : Evergreen.V36.Element.Color
    , debugAlert : Evergreen.V36.Element.Color
    , link : Evergreen.V36.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
