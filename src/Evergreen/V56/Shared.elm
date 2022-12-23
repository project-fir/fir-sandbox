module Evergreen.V56.Shared exposing (..)

import Evergreen.V56.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V56.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V56.Ui.PaletteName
