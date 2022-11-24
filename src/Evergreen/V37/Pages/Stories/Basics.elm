module Evergreen.V37.Pages.Stories.Basics exposing (..)

import Evergreen.V37.Ui


type alias Model =
    { theme : Evergreen.V37.Ui.ColorTheme
    , isDrawerOpen : Bool
    }


type Msg
    = Basics__UserSelectedPalette Evergreen.V37.Ui.PaletteName
    | UserToggledDrawer
    | Noop
