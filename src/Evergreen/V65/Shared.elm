module Evergreen.V65.Shared exposing (..)

import Evergreen.V65.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V65.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V65.Ui.PaletteName
