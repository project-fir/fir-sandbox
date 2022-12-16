module Evergreen.V48.Shared exposing (..)

import Evergreen.V48.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V48.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V48.Ui.PaletteName
