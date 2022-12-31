module Evergreen.V63.Shared exposing (..)

import Evergreen.V63.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V63.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V63.Ui.PaletteName
