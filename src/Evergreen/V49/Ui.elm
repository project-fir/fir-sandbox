module Evergreen.V49.Ui exposing (..)

import Evergreen.V49.Element


type alias ColorTheme =
    { primary1 : Evergreen.V49.Element.Color
    , primary2 : Evergreen.V49.Element.Color
    , secondary : Evergreen.V49.Element.Color
    , background : Evergreen.V49.Element.Color
    , deadspace : Evergreen.V49.Element.Color
    , white : Evergreen.V49.Element.Color
    , gray : Evergreen.V49.Element.Color
    , black : Evergreen.V49.Element.Color
    , debugWarn : Evergreen.V49.Element.Color
    , debugAlert : Evergreen.V49.Element.Color
    , link : Evergreen.V49.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
