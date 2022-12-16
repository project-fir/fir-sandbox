module Evergreen.V49.Shared exposing (..)

import Evergreen.V49.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V49.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V49.Ui.PaletteName
