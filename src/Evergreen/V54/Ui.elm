module Evergreen.V54.Ui exposing (..)

import Evergreen.V54.Element


type alias ColorTheme =
    { primary1 : Evergreen.V54.Element.Color
    , primary2 : Evergreen.V54.Element.Color
    , secondary : Evergreen.V54.Element.Color
    , background : Evergreen.V54.Element.Color
    , deadspace : Evergreen.V54.Element.Color
    , white : Evergreen.V54.Element.Color
    , gray : Evergreen.V54.Element.Color
    , black : Evergreen.V54.Element.Color
    , debugWarn : Evergreen.V54.Element.Color
    , debugAlert : Evergreen.V54.Element.Color
    , link : Evergreen.V54.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
