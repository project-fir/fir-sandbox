module Evergreen.V52.Pages.Stories.Basics exposing (..)

import Evergreen.V52.Ui


type alias Model =
    { theme : Evergreen.V52.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type Msg
    = Basics__UserSelectedPalette Evergreen.V52.Ui.PaletteName
    | UserToggledDrawer
    | MouseEnteredDropDownMenu
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
