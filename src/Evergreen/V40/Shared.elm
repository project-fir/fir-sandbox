module Evergreen.V40.Shared exposing (..)

import Evergreen.V40.Ui
import Time


type alias Model =
    { zone : Time.Zone
    , selectedTheme : Evergreen.V40.Ui.ColorTheme
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette Evergreen.V40.Ui.PaletteName
