module Evergreen.V39.Shared exposing (..)

import Evergreen.V39.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V39.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V39.Ui.PaletteName
