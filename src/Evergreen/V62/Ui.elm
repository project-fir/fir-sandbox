module Evergreen.V62.Ui exposing (..)

import Evergreen.V62.Element


type alias ColorTheme =
    { primary1 : Evergreen.V62.Element.Color
    , primary2 : Evergreen.V62.Element.Color
    , secondary : Evergreen.V62.Element.Color
    , background : Evergreen.V62.Element.Color
    , deadspace : Evergreen.V62.Element.Color
    , white : Evergreen.V62.Element.Color
    , gray : Evergreen.V62.Element.Color
    , black : Evergreen.V62.Element.Color
    , debugWarn : Evergreen.V62.Element.Color
    , debugAlert : Evergreen.V62.Element.Color
    , link : Evergreen.V62.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
