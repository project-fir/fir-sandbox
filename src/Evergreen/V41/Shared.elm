module Evergreen.V41.Shared exposing (..)

import Evergreen.V41.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V41.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V41.Ui.PaletteName
