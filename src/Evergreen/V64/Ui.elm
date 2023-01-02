module Evergreen.V64.Ui exposing (..)

import Evergreen.V64.Element


type alias ColorTheme =
    { primary1 : Evergreen.V64.Element.Color
    , primary2 : Evergreen.V64.Element.Color
    , secondary : Evergreen.V64.Element.Color
    , background : Evergreen.V64.Element.Color
    , deadspace : Evergreen.V64.Element.Color
    , white : Evergreen.V64.Element.Color
    , gray : Evergreen.V64.Element.Color
    , black : Evergreen.V64.Element.Color
    , debugWarn : Evergreen.V64.Element.Color
    , debugAlert : Evergreen.V64.Element.Color
    , link : Evergreen.V64.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
