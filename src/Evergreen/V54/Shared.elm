module Evergreen.V54.Shared exposing (..)

import Evergreen.V54.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V54.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V54.Ui.PaletteName
