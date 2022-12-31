module Evergreen.V62.Shared exposing (..)

import Evergreen.V62.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V62.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V62.Ui.PaletteName
