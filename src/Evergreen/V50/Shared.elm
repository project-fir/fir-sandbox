module Evergreen.V50.Shared exposing (..)

import Evergreen.V50.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V50.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V50.Ui.PaletteName
