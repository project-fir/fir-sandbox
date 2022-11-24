module Evergreen.V37.Shared exposing (..)

import Evergreen.V37.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V37.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V37.Ui.PaletteName
