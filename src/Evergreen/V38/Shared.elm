module Evergreen.V38.Shared exposing (..)

import Evergreen.V38.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V38.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V38.Ui.PaletteName
