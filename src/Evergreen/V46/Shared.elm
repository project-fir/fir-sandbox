module Evergreen.V46.Shared exposing (..)

import Evergreen.V46.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V46.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V46.Ui.PaletteName
