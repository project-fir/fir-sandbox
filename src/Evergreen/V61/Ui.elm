module Evergreen.V61.Ui exposing (..)

import Evergreen.V61.Element


type alias ColorTheme =
    { primary1 : Evergreen.V61.Element.Color
    , primary2 : Evergreen.V61.Element.Color
    , secondary : Evergreen.V61.Element.Color
    , background : Evergreen.V61.Element.Color
    , deadspace : Evergreen.V61.Element.Color
    , white : Evergreen.V61.Element.Color
    , gray : Evergreen.V61.Element.Color
    , black : Evergreen.V61.Element.Color
    , debugWarn : Evergreen.V61.Element.Color
    , debugAlert : Evergreen.V61.Element.Color
    , link : Evergreen.V61.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
