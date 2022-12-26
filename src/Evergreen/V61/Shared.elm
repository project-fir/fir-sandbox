module Evergreen.V61.Shared exposing (..)

import Evergreen.V61.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V61.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V61.Ui.PaletteName
