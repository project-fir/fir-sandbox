module Evergreen.V43.Shared exposing (..)

import Evergreen.V43.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V43.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V43.Ui.PaletteName
