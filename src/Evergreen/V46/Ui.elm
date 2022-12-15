module Evergreen.V46.Ui exposing (..)

import Evergreen.V46.Element


type alias ColorTheme =
    { primary1 : Evergreen.V46.Element.Color
    , primary2 : Evergreen.V46.Element.Color
    , secondary : Evergreen.V46.Element.Color
    , background : Evergreen.V46.Element.Color
    , deadspace : Evergreen.V46.Element.Color
    , white : Evergreen.V46.Element.Color
    , gray : Evergreen.V46.Element.Color
    , black : Evergreen.V46.Element.Color
    , debugWarn : Evergreen.V46.Element.Color
    , debugAlert : Evergreen.V46.Element.Color
    , link : Evergreen.V46.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
