module Evergreen.V48.Ui exposing (..)

import Evergreen.V48.Element


type alias ColorTheme =
    { primary1 : Evergreen.V48.Element.Color
    , primary2 : Evergreen.V48.Element.Color
    , secondary : Evergreen.V48.Element.Color
    , background : Evergreen.V48.Element.Color
    , deadspace : Evergreen.V48.Element.Color
    , white : Evergreen.V48.Element.Color
    , gray : Evergreen.V48.Element.Color
    , black : Evergreen.V48.Element.Color
    , debugWarn : Evergreen.V48.Element.Color
    , debugAlert : Evergreen.V48.Element.Color
    , link : Evergreen.V48.Element.Color
    }


type PaletteName
    = BambooBeach
    | CoffeeRun
    | Nitro
