module Evergreen.V52.Ui exposing (..)

import Evergreen.V52.Element


type alias ColorTheme =
    { primary1 : Evergreen.V52.Element.Color
    , primary2 : Evergreen.V52.Element.Color
    , secondary : Evergreen.V52.Element.Color
    , background : Evergreen.V52.Element.Color
    , deadspace : Evergreen.V52.Element.Color
    , white : Evergreen.V52.Element.Color
    , gray : Evergreen.V52.Element.Color
    , black : Evergreen.V52.Element.Color
    , debugWarn : Evergreen.V52.Element.Color
    , debugAlert : Evergreen.V52.Element.Color
    , link : Evergreen.V52.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
