module Evergreen.V38.Pages.Stories.Basics exposing (..)

import Evergreen.V38.Ui


type alias Model =
    { theme : Evergreen.V38.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type Msg
    = Basics__UserSelectedPalette Evergreen.V38.Ui.PaletteName
    | UserToggledDrawer
    | MouseEnteredDropDownMenu
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
