module Evergreen.V64.Shared exposing (..)

import Evergreen.V64.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V64.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V64.Ui.PaletteName
