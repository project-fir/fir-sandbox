module Evergreen.V49.Pages.Stories.Basics exposing (..)

import Evergreen.V49.Ui


type alias Model =
    { theme : Evergreen.V49.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type Msg
    = Basics__UserSelectedPalette Evergreen.V49.Ui.PaletteName
    | UserToggledDrawer
    | MouseEnteredDropDownMenu
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
