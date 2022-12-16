module Evergreen.V52.Shared exposing (..)

import Evergreen.V52.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V52.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V52.Ui.PaletteName
