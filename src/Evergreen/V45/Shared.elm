module Evergreen.V45.Shared exposing (..)

import Evergreen.V45.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V45.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V45.Ui.PaletteName
