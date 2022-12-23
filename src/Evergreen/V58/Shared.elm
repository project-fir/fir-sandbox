module Evergreen.V58.Shared exposing (..)

import Evergreen.V58.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V58.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V58.Ui.PaletteName
