module Evergreen.V36.Pages.Stories.Basics exposing (..)

import Evergreen.V36.Ui


type alias Model =
    { selectedTheme : Evergreen.V36.Ui.ColorTheme
    }


type Msg
    = UserSelectedPalette Evergreen.V36.Ui.PaletteName
