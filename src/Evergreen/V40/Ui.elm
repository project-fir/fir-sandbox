module Evergreen.V40.Ui exposing (..)

import Evergreen.V40.Element


type alias ColorTheme =
    { primary1 : Evergreen.V40.Element.Color
    , primary2 : Evergreen.V40.Element.Color
    , secondary : Evergreen.V40.Element.Color
    , background : Evergreen.V40.Element.Color
    , deadspace : Evergreen.V40.Element.Color
    , white : Evergreen.V40.Element.Color
    , gray : Evergreen.V40.Element.Color
    , black : Evergreen.V40.Element.Color
    , debugWarn : Evergreen.V40.Element.Color
    , debugAlert : Evergreen.V40.Element.Color
    , link : Evergreen.V40.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
