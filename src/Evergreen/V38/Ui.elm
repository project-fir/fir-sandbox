module Evergreen.V38.Ui exposing (..)

import Evergreen.V38.Element


type alias ColorTheme =
    { primary1 : Evergreen.V38.Element.Color
    , primary2 : Evergreen.V38.Element.Color
    , secondary : Evergreen.V38.Element.Color
    , background : Evergreen.V38.Element.Color
    , deadspace : Evergreen.V38.Element.Color
    , white : Evergreen.V38.Element.Color
    , gray : Evergreen.V38.Element.Color
    , black : Evergreen.V38.Element.Color
    , debugWarn : Evergreen.V38.Element.Color
    , debugAlert : Evergreen.V38.Element.Color
    , link : Evergreen.V38.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
